class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification)
    # Do something later
    logger = Logger.new("#{Rails.root}/log/sidekiq_scheduled_task.log",1, 20*1024*1024)
    logger.info("====================================================")
    logger.info("ProcessNotificationJobs: started at #{Time.now.to_s}")
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        notification.push_notification_to_device
        logger.info("ProcessNotificationJobs: done #{notification.try(:id)}")

      end
    rescue => e
      logger.info(e.backtrace.join("\n"))
      logger.info(e.message)
      raise e.message
    end
  end
end
