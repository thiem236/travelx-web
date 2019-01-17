class ApplicationController < ActionController::Base
  Swagger::Docs::Generator::set_real_methods
  include ApplicationResponder
  include DeviseTokenAuth::Concerns::SetUserByToken
  # include DeviseTokenAuth::Concerns::SetUserByToken

end
