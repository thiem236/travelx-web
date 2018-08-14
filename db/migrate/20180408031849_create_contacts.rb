class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.string :contact
      t.integer :contact_type
      t.boolean :has_contact, default: :false

      t.timestamps
    end
    add_foreign_key :contacts, :users , column: :user_id
  end
end
