require 'sidekiq/web'
redis_conn = proc {
  Redis.new(url: "#{ENV["REDIS_URL"]}/12")
}
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end
Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
  config.error_handlers << Proc.new {|ex,ctx_hash| MyErrorService.notify(ex, ctx_hash) }
end
Sidekiq::Extensions.enable_delay!