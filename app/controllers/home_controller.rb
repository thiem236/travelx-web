class HomeController < ApplicationController
  def index
  end

  def apple_app_site
    render json: {
        "applinks": {
            "apps": [],
            "details": [
                {
                    "appID": "AQC5VRATZH.sg.utomedia.mobile",
                    "paths": [
                        "*"
                    ]
                }
            ]
        }
    }
  end
end