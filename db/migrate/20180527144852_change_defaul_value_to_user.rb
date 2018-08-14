class ChangeDefaulValueToUser < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :device_tokens,:jsonb, default: []
  end
end
