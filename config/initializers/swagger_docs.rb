class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    "apidocs/#{path}"
  end
  def self.base_api_controller; [ActionController::API, ActionController::Base] end
end

Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/apidocs",
    # the URL base path to your API
    :base_path => Rails.application.config.site_url,
    # if you want to delete all .json files at each generation
    :clean_directory => false,
    # Ability to setup base controller for each api version. Api::V1::SomeController for example.
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Travel API documentation",
        "description" => "",
        "termsOfServiceUrl" => "",
        "contact" => "",
        "license" => "Apache 2.0",
        "licenseUrl" => "http://www.apache.org/licenses/LICENSE-2.0.html"
      }
    },
    :custom_apis => [{
      :path=>"/apidocs/auth",
      :description=>"Auth"
    }],
    :camelize_model_properties => false

  }
})
