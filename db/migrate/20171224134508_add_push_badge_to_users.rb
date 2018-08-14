class AddPushBadgeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :push_badge, :integer, default:  1
  end
end
