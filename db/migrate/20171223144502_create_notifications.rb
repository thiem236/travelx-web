class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'
    enable_extension 'uuid-ossp'

    create_table :notifications,id: :uuid do |t|
      t.string :message_id
      t.string :device_id
      t.string :device
      t.integer :user_id
      t.string :event
      t.jsonb :responds
      t.jsonb :body
      t.bigint :sent_at
      t.bigint :read_at
      t.jsonb :setting

      t.timestamps
    end
  end
end
