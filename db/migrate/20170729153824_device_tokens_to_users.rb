class DeviceTokensToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :device_tokens, :jsonb, default: []
    add_index  :users, :device_tokens, using: :gin
  end
end
