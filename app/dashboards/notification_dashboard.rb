require "administrate/base_dashboard"

class NotificationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    sender: Field::BelongsTo.with_options(class_name: "User"),
    id: Field::String.with_options(searchable: false),
    message_id: Field::String,
    device_id: Field::String,
    device: Field::String,
    event: Field::String,
    responds: Field::JSON,
    body: Field::JSON,
    sent_at: Field::Number,
    read_at: Field::Number,
    setting: Field::JSON,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String,
    obj: Field::JSON,
    model_type: Field::String,
    noti_type: Field::String,
    sender_id: Field::Number,
    title: Field::String,
    is_unread: Field::Boolean,
    is_hidden: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :title,
    :sender,
    :id,
    :message_id,
    :model_type,
    :sent_at,
    :read_at,
    :created_at,
    :status,
    :noti_type,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :sender,
    :id,
    :message_id,
    :device_id,
    :device,
    :event,
    :responds,
    :body,
    :sent_at,
    :read_at,
    :setting,
    :created_at,
    :updated_at,
    :status,
    :obj,
    :model_type,
    :noti_type,
    :sender_id,
    :title,
    :is_unread,
    :is_hidden,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :sender,
    :message_id,
    :device_id,
    :device,
    :event,
    :responds,
    :body,
    :sent_at,
    :read_at,
    :setting,
    :status,
    :obj,
    :model_type,
    :noti_type,
    :sender_id,
    :title,
    :is_unread,
    :is_hidden,
  ].freeze

  # Overwrite this method to customize how notifications are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(notification)
  #   "Notification ##{notification.id}"
  # end
end
