require "open-uri"
class Api::V1::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  # Swagger::Docs::Generator::set_real_methods

  include ApplicationResponder
  respond_to :json
  swagger_controller :OmniauthCallbacks, "OmniauthCallbacks"

  swagger_api :omniauth_success do |api|
    summary "Create a new User with face book"
    param :query, :access_token, :string, :require, 'access_token'
    param :query, :expires_in, :integer, :require, "expires_in"
    param :query, :country, :string, :require, "country"
    param :query, :platform, :string, :require, "ios/android"
    param :query, :device_token, :string, :require, "Device toke"
    param :query, :user_id, :string, :optional, "User invite"
    param :path, :provider, :string, :require, "[facebook,google_oauth2]"

    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end

  def omniauth_success
    begin
      provider = params[:provider]
      case provider
        when 'facebook'
          message = get_resource_from_facebook(params[:access_token],params[:expires_in])
        when 'google_oauth2'
          message = get_resource_from_google(params[:access_token])
        else
          "You gave me -- I have no idea what to do with that."
      end
      if @resource.present?
        create_token_info
        set_token_on_resource
        create_auth_params
        sign_in(:user, @resource, store: false, bypass: false)

        @resource.save!
        update_auth_header

        yield @resource if block_given?

        respond_with @resource
      else
        if message.present?
          respond_error message
        else
          respond_error "Token invaild"
        end

      end

    rescue Exception => e
      Rails.logger.info(hash_exception(e))
      respond_error "Error validating access token", :unauthorized
    end

  end

  protected
  def get_resource_from_facebook(access_token, expires_in)
    platform = if params["platform"] =='ios' then 'ios' else 'android' end
    graph = Koala::Facebook::API.new(access_token)
    profile = graph.get_object('me?fields=email,name,id,picture')
    if User.exists?(uid:  profile['email'])
      return "Email has been exist"
    end
    @resource = User.find_or_initialize_by(uid:      profile['id'],provider: 'facebook')

    @resource.fb_id ||= profile['id']
    @resource.email ||= profile['email']
    @resource.name ||= profile['name']
    @resource.oauth_token = access_token
    @resource.country ||= params[:country]
    @resource.verified = true
    # user.password = Devise.friendly_token[0,20]
    unless @resource.profile_picture_id
      @resource.profile_picture  = open("http://graph.facebook.com/"+profile['id']+"/picture?width=142&height=142")
      @resource.profile_picture_filename  = "facebook_profile.jpeg"
    end
    @resource.oauth_expires_at = Time.at(expires_in.to_i)
    @resource.device_tokens = [{device_token: params['device_token'], device_name: platform}] if params['device_token'].present?
      # user.skip_confirmation!
    if @resource.new_record?
      if params[:user_id].present?
        invite  = Invite.find_by(sent_by: params[:user_id])
        if invite.present?
          @resource.invited_by_id = invite.sent_by
          @resource.contact = invite.contact
          @resource.invitation_accepted_at = Time.zone.now
          invite.destroy
        end
      end
      @oauth_registration = true
      set_random_password
    end
    @resource.save!
  end

  def get_resource_from_google(token)
    response = ::HTTParty.get("https://www.googleapis.com/oauth2/v2/userinfo",
                            headers: {"Access_token"  => token,
                                      'X-Requested-With' => 'XMLHttpRequest',
                                      "Authorization" => "OAuth #{token}"})
    if response.code == 200
      data = JSON.parse(response.body)
      @resource = User.where({uid:data['id'],provider: 'google_oauth2'}).first_or_initialize do |user|
        user.uid = data['id']
        user.email = data['email']
        user.provider = 'google_oauth2'
        user.oauth_token =  token
        user.name = data['name']
        user.gender = data['gender']
        user.image_url = data['picture'] if data['picture'].present?
      end

      if @resource.new_record?
        @oauth_registration = true
        set_random_password
      end
      @resource.save!
    end
    response.code

  end
  def resource_class(mapping = nil)
    'User'
  end
end