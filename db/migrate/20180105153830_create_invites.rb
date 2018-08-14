class CreateInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :invites do |t|
      t.string :contact
      t.string :country
      t.bigint :invited_at
      t.bigint :accept_invite_at
      t.string :token
      t.integer :sent_by

      t.timestamps
    end
    add_index :invites, :token,                unique: true
    add_foreign_key :invites, :users , column: :sent_by
  end
end
