class AddAbleIdAbleTypeToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :able_id, :integer
    add_column :notifications, :able_type, :string
    add_column :notifications, :is_delete, :boolean, default: false
  end
end
