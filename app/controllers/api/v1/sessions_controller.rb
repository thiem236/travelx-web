# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
  include ApplicationResponder
  # Swagger::Docs::Generator::set_real_methods
  swagger_controller :sessions, "SessionsController"

  swagger_api :create do |api|
    summary "Login user"
    param :form, :email, :string, :require, 'email'
    param :form, :password, :string, :require, "password"
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      super
    rescue StandardError => e
      Rails.logger.info(hash_exception(e))
      respond_error "Username or password is not correct"
    end
  end

  swagger_api :destroy do |api|
    summary "Logout user"
    Api::ApiController.add_common_params(self)
    param :form, :device_token, :string, :require, 'email'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def destroy
    # remove auth instance variables so that after_action does not run
    user = remove_instance_variable(:@resource) if @resource
    client_id = remove_instance_variable(:@client_id) if @client_id
    remove_instance_variable(:@token) if @token

    if user && client_id && user.tokens[client_id]
      user.tokens.delete(client_id)
      user.device_tokens.select!{|c| c['device_token'] != params['device_token'].try(:strip)}
      user.save!

      yield user if block_given?

      render_destroy_success
    else
      render_destroy_error
    end
  end

  protected

  def render_create_success
    # render json: {
    #     data: resource_data(resource_json: @resource.token_validation_response)
    # }
    render json: { data: UserSerializer.new(@resource) }
  end
  def render_create_error_not_confirmed
    render json: {
        success: false,
        errors:  "Please verify account" 
    }, status: 401
  end

  def render_create_error_bad_credentials
    render json: {
        errors: 'Username or password is not correct'
    }, status: 401
  end

end

