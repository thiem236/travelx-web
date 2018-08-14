class CreateStamps < ActiveRecord::Migration[5.1]
  def change
    create_table :stamps do |t|
      t.string :country
      t.string :image_id
      t.string :image_filename
      t.integer :user_id
      t.string :type

      t.timestamps
    end
    add_foreign_key :stamps, :users , column: :user_id
  end
end
