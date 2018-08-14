class Api::ApiController < ActionController::API
  Swagger::Docs::Generator::set_real_methods
  include ApplicationResponder
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  respond_to :json

  def self.add_common_params(api)
    api.param :header, 'access-token', :string, :optional, 'Access token'
    api.param :header, 'client', :string, :optional, 'Client'
    api.param :header, 'uid', :string, :optional, 'UID'
  end

end