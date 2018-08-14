require 'active_support/concern'

module NotificationConcern
  extend ActiveSupport::Concern
  included do
    after_destroy :delete_notification
  end

  def delete_notification
    Notification.where(able_type: self.class.name, able_id: id).destroy_all
  end
end