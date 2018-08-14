class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include ApplicationResponder
  # Swagger::Docs::Generator::set_real_methods
  swagger_controller :registrations, 'RegistrationsController'
  # swagger_model :sign_up do
  #   description "User object."
  #   property 'email', :string, :require, 'Email'
  #   property 'first_name', :string, :require, 'First Name'
  #   property 'last_name', :string, :require, 'Last Name'
  #   property 'password', :string, :require, 'password'
  #   property 'password_confirmation', :string, :require, 'password'
  # end

  swagger_api :create do |api|
    summary 'Create a new User item'
    # param :body, :sign_up, :sign_up, :require, 'User object'
    param :form, 'email', :string, :require, 'Email'
    param :form, 'name', :string, :require, 'First Name'
    param :form, 'country', :string, :require, 'country code'
    param :form, 'password', :string, :require, 'password'
    param :form, 'contact', :string, :require, 'Contact'
    param :form, 'password_confirmation', :string, :require, 'password'
    param :form, 'user_id', :string, :optional, 'User invite'
    param :form, :platform, :string, :optional, "ios/android"
    param :form, :device_token, :string, :optional, "Device toke"
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end

  def create
    @resource = User.find_by(email: sign_up_params[:email].strip)
    
    if @resource.present? && !@resource.verified?
      @resource.update_attributes(sign_up_params)
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      @resource.save!

      update_auth_header
      @resource.delay.generate_verification_code_and_send
      render_create_success and return
    end
    if params[:invite_token].present?
      invite  = Invite.find_by_token(params[:invite_token])

    end
    @resource            = resource_class.new(sign_up_params)
    @resource.provider   = "email"

    if params[:user_id].present?
      invite  = Invite.find_by(sent_by: params[:user_id])
      if invite.present?
        @resource.invited_by_id = invite.sent_by
        @resource.contact = invite.contact
        @resource.invitation_accepted_at = Time.zone.now
        invite.destroy
      end

    end

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @resource.email = sign_up_params[:email].try :downcase
    else
      @resource.email = sign_up_params[:email]
    end

    # give redirect value from params priority
    @redirect_url = params[:confirm_success_url]

    # fall back to default value if provided
    @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

    # success redirect url is required
    if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
      return render_create_error_missing_confirm_success_url
    end

    # if whitelist is set, validate redirect_url against whitelist
    if DeviseTokenAuth.redirect_whitelist
      unless DeviseTokenAuth::Url.whitelisted?(@redirect_url)
        return render_create_error_redirect_url_not_allowed
      end
    end

    begin
      # override email confirmation, must be sent manually from ctrl
      resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        yield @resource if block_given?

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
                                                       client_config: params[:config_name],
                                                       redirect_url: @redirect_url
                                                   })

        else
          # email auth has been bypassed, authenticate user
          @client_id = SecureRandom.urlsafe_base64(nil, false)
          @token     = SecureRandom.urlsafe_base64(nil, false)

          @resource.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
          }

          @resource.save!

          update_auth_header
        end
        @resource.delay.generate_verification_code_and_send
        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique

      clean_up_passwords @resource
      render_create_error_email_already_exists
    rescue => e
      puts e
      respond_error(e.message)
    end

  end

  protected

  def render_create_error_missing_confirm_success_url
    render json: {
        status: 'error',
        data:   resource_data,
        errors: [I18n.t("devise_token_auth.registrations.missing_confirm_success_url")]
    }, status: 422
  end

  def render_create_error_redirect_url_not_allowed
    render json: {
        status: 'error',
        errors: [I18n.t("devise_token_auth.registrations.redirect_url_not_allowed", redirect_url: @redirect_url)]
    }, status: 422
  end

  def render_create_error
    respond_error(resource_errors[:full_messages].try(:first), 422) and return
  end

  def render_create_error_email_already_exists
    respond_error("Email is already_exists", 422) and return
  end

  def render_update_success
    render json: {
        status: 'success',
        data:   UserSerializer.new(resource_data)
    }
  end

  def render_update_error
    render json: {
        status: 'error',
        errors: resource_errors
    }, status: 422
  end

  def render_update_error_user_not_found
    render json: {
        status: 'error',
        errors: [I18n.t("devise_token_auth.registrations.user_not_found")]
    }, status: 404
  end

  def render_destroy_success
    render json: {
        status: 'success',
        message: I18n.t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.uid)
    }
  end

  def render_destroy_error
    render json: {
        status: 'error',
        errors: [I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")]
    }, status: 404
  end


  def sign_up_params
    params[:device_tokens] = [{device_token: params[:device_token], device_name: params[:platform]}]
    params.permit(:name,
                  :email,
                  :password,
                  :password_confirmation,
                  :contact,
                  :country,
                  device_tokens: [:device_token,:device_name, :badge ]
    )
  end

  def render_create_success
    render json: { data: UserSerializer.new(@resource) }
  end
end
