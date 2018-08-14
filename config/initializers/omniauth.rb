Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,      ENV['FACEBOOK_API'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_SECRET_KEY'],   ENV['GOOGLE_CLIENT_ID']
end
