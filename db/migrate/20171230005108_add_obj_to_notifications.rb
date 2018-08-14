class AddObjToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :obj, :jsonb, default: {}
    add_column :notifications, :model_type, :string
    add_column :notifications, :noti_type, :string
    add_column :notifications, :sender_id, :integer
    add_column :notifications, :title, :string
    add_column :notifications, :is_unread, :boolean, default: true
    add_column :notifications, :is_hidden, :boolean, default: false
  end
end