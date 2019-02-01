source 'https://rubygems.org'
ruby '2.4.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Use sqlite3 as the database for Active Record
# Use Puma as the app server
gem 'puma', '~> 3.7'
gem 'pg', '~> 0.18'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
#documentation
gem 'swagger-docs'
# gem 'swagger-blocks'
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# background jobs
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-failures'

gem 'devise'
gem 'devise_invitable'
gem 'devise_token_auth'
gem 'seed-fu', '~> 2.3'
gem "pundit"
gem "httparty"
gem "responders"
gem 'active_model_serializers', '~> 0.10.6'
gem 'default_value_for', '~> 3.0', '>= 3.0.2'


gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth'
gem 'awesome_print', require: 'ap'
gem 'koala'
gem 'jwt'
gem 'refile', github: 'refile/refile', require: 'refile/rails'
gem 'refile-mini_magick', github: 'refile/refile-mini_magick'
gem "refile-s3"
gem 'bootstrap-sass'
gem 'factory_bot'
gem 'versionist'
gem "haml-rails", "~> 1.0"
gem 'geocoder'
gem 'phone'
gem 'countries', :require => 'countries/global'
# gem 'restcountry'
gem "jsonb_accessor", "~> 1.0.0"
gem 'active_record_upsert'


# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# env vars
gem 'figaro'
gem 'enumerize'
gem 'has_friendship'
gem 'numbers_in_words'
gem 'rotp'
gem 'storext'
gem 'countries'
gem 'city-state'
gem 'telephone_number'
gem 'kaminari'


group :development, :test do
  gem 'pry'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'faker'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  ## Capistrano
  gem 'capistrano', '3.9.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-collection'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-puma'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'better_errors'
end
gem 'draper'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "administrate", github: 'thoughtbot/administrate'
gem 'administrate-field-json', github: 'eddietejeda/administrate-field-json', branch: 'master'

gem 'twilio-ruby'
gem 'textris'

