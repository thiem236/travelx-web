class Notification < ApplicationRecord
  attribute :is_unread, :boolean, default: true
  attribute :is_hidden, :boolean, default: false

  extend Enumerize
  jsonb_accessor :setting,
                 push_device: :boolean,
                 send_sms: :boolean
  jsonb_accessor :responds,
                 data: :jsonb,
                 status_code: :integer

  after_create :queue_send_notification
  enumerize :status, in: AppConstants::Notification::STATUS, predicates: true, scope: true
  enumerize :noti_type, in: AppConstants::Notification::NOTIFICATION_TYPE, predicates: true, scope: true
  belongs_to :user
  belongs_to :sender, class_name: 'User',foreign_key: :sender_id, optional: true

  scope :avaiable, ->{where is_hidden: false}
  scope :unread, ->{where(is_unread: true)}


  def push_notification_to_device
    if device_id
      firebase_service = FirebaseServices.new(device_ids: [device_id],payload: body.to_json)
      res = firebase_service.send_single_devise
      result = res.as_json['results']
      if result
        self.data = result
        self.message_id = result.first['message_id']
        self.status_code = res.response.code
        self.status = 'sending'
        self.sent_at = Time.zone.now.to_i
        self.save!
      end
    end
  end

  def queue_send_notification
    unless sent_at.present?
      PushNotificationJob.perform_now(self)
    end

  end

  AppConstants::Notification::NOTIFICATION_TYPE.each do |noti|

    define_method "#{noti}!" do
      title = ""
      title = "You have accepted to join #{sender.try(:name)}'s trip" if noti == 'accept_trip'
      title = "You have ignored to join #{sender.try(:name)}'s trip" if noti == 'reject_invite_trip'
      self.noti_type = noti
      self.title = title if title.present?
      self.save!
    end
  end

  def self.read_all!(user_id)
    Notification.where.not(noti_type: ['invited_friend','accepted_friend'])
        .where(user_id: user_id).update_all(is_unread: false, read_at: Time.zone.now.to_i)
  end

  def self.read_all_friend_noti!(user_id)
    Notification.where(noti_type: ['invited_friend','accepted_friend'])
        .where(user_id: user_id).update_all(is_unread: false, read_at: Time.zone.now.to_i)
  end

  def self.clear_all!(user_id)
    Notification.where(user_id: user_id).update_all(is_hidden: true)
  end

end
