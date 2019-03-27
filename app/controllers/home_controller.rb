class HomeController < ApplicationController
  def index
  end
  
  def apple_app_site
    association_json = File.read(Rails.public_path + "apple-app-site-association")
    render :json => association_json, :content_type => "application/json"
  end

end