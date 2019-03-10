class HomeController < ApplicationController
  def index
  end
  
  def apple_app_site
    association_json = File.read(Rails.public_path + "apple_app_site_association")
    render :json => association_json, :content_type => "application/json"
  end

end