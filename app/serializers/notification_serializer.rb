class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :message_id, :user_id, :title, :responds, :body,
             :sent_at, :read_at, :created_at, :status, :obj,
                :model_type, :noti_type, :sender_id, :is_unread
  belongs_to :user
  belongs_to :sender

  def created_at
    object.created_at.to_i
  end
end

