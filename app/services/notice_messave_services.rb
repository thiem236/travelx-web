class NoticeMessaveServices
  attr_reader :message,:users, :user_device_ids
  MAX_USER_IDS_PER_CALL = 1000
  def initialize(user_ids, message)
    @users = User.where(id: user_ids)
    @user_device_ids = @users.pluck(:device_tokens).collect{|device| device.values}.flatten
    @message = message
  end

  def call
    user_device_ids.each_slice(MAX_USER_IDS_PER_CALL) do |device_ids|
      fcm_client.send(device_ids, options)
    end
  end


  private

  def options
    {
        priority: 'high',
        data: {
            message: message
        },
        notification: {
            body: message,
            sound: 'default'
        }
    }
  end

  def fcm_client
    @fcm_client ||= FCM.new(ENV[:GOOGLE_SECRET_KEY])
  end
end