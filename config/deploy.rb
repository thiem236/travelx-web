ENV.update YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
lock "3.11.0"
set :stages, %w(production staging)

set :nginx_config,    ENV['TRAVELX_NGINX_CONFIG']
set :repo_url,        ENV['TRAVELX_REPO_URL']
set :application,     ENV['TRAVELX_APP_NAME']
set :user,            ENV['TRAVELX_USER_DEPLOY']
set :puma_threads,    [4, 16]
# Config ruby version
set :rbenv_type, :user # or :system, depends on your rbenv setup

# Don't change these unless you know what you're doing
set :use_sudo,        false
set :deploy_via,      :remote_cache
# set :deploy_to,       "/var/www/#{fetch(:application)}"
set :deploy_to,       "/home/#{fetch(:user)}/deploy"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :branch, ENV['TRAVELX_REPO_BRANCH']
set :format,        :pretty
set :log_level,     :debug
set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/config.yml config/secrets.yml config/database.yml config/sidekiq.yml}
set :linked_dirs,  %w{log tmp vendor public}

# Sidekiq
set :pty,         false
set :sidekiq_config, "#{shared_path}/config/sidekiq.yml"

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Copy files'
  task :copy do
    on roles(:all) do
      database = File.join(File.dirname(__FILE__), 'database.yml')
      secrets = File.join(File.dirname(__FILE__), 'secrets.yml')
      config_path = File.join(File.dirname(__FILE__), 'config.yml')
      sidekiq_path = File.join(File.dirname(__FILE__), 'sidekiq.yml')
      # nginx_path = fetch(:stage) == :production ? File.join(File.dirname(__FILE__), 'nginx.prod.conf') : File.join(File.dirname(__FILE__), 'nginx.conf')
      # upload! nginx_path, "#{shared_path}/config/nginx.conf"
      upload! config_path, "#{shared_path}/config/config.yml"
      upload! database, "#{shared_path}/config/database.yml"
      upload! secrets, "#{shared_path}/config/secrets.yml"
      upload! sidekiq_path, "#{shared_path}/config/sidekiq.yml"
    end
  end

  # desc 'Nginx'
  # task :nginx do
  #   on roles(:all) do
  #     execute "sudo ln -nfs /var/www/travelx/shared/config/nginx.conf /etc/nginx/conf.d/travelx-api.conf"
  #     execute "sudo service nginx restart"
  #   end
  # end

  before 'deploy:check:linked_files', :copy
  # after  :finishing, :nginx
  after  :finishing, :cleanup
  after  :finishing, :restart
end

