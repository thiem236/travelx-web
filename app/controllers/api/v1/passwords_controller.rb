class Api::V1::PasswordsController < DeviseTokenAuth::PasswordsController
  before_action :set_user_by_token, :only => [:update]
  skip_after_action :update_auth_header, :only => [ :edit]
  include ApplicationResponder


  # this action is responsible for generating password reset tokens and
  # sending emails
  swagger_controller :sessions, "SessionsController"

  swagger_api :create do
    summary "Create new trip"
    param :form, :email, :string, :require, 'email'
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      user = User.find_by(email: params[:email])
      if user.nil?
        respond_error("This email has not been registered")
        return
      end
      user.generate_verification_code_and_send_reset_pass
      respond_success 'Reset code send your email'
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error(e.message)
    end
  end

  swagger_api :update do
    summary "Create new trip"
    param :form, :auth_token, :string, :require, 'auth token'
    param :form, :email, :string, :require, 'email'
    param :form, :password, :string, :require, 'password'
    param :form, :password_confirmation, :string, :require, 'password_confirmation'
    response :not_acceptable
    response :unprocessable_entity
  end
  def update
    begin
      @user = User.find_by(email: params[:email], auth_token: params[:auth_token])
      unless @user
        respond_error('invalid token')
        return
      end
      @user.update_attributes!(password: params[:password],password_confirmation: params[:password_confirmation])
      create_token_info
      create_auth_params
      set_token_on_resource
      sign_in(:user, @user, store: false, bypass: false)

      @user.save!
      auth_header = @user.create_new_auth_token(@client_id)

      # update the response header
      response.headers.merge!(auth_header)

      # update the response header
      respond_success("password changed success")
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error(e.message)
    end
  end

  # this is where users arrive after visiting the password reset confirmation link
  swagger_api :check_code do
    summary "Create new trip"
    param :form, :email, :string, :require, 'email'
    param :form, :code, :string, :require, 'code'
    response :not_acceptable
    response :unprocessable_entity
  end
 def check_code
   begin
     user = User.find_by(email: params[:email])
     if user.nil?
       respond_error("This email has not been registered") and return
     end
     user.verify_reset_pass(params[:code])
     respond_without_location email: user.email, auth_token: user.auth_token
   rescue =>e
     Rails.logger.info(e.backtrace.join("\n"))
     Rails.logger.info(e.message)
     respond_error("Code is invaild")
   end

 end
  protected

  def create_token_info
    # create token info
    @client_id = SecureRandom.urlsafe_base64(nil, false)
    @token     = SecureRandom.urlsafe_base64(nil, false)
    @expiry    = (Time.now + DeviseTokenAuth.token_lifespan).to_i
  end


  def create_auth_params
    @auth_params = {
        auth_token:     @token,
        client_id: @client_id,
        uid:       @user.uid,
        expiry:    @expiry,
    }
    @auth_params
  end
  def set_token_on_resource
    @user.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: @expiry
    }
  end


end