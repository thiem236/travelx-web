class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.integer :trip_id
      t.string :post_type
      t.string :content
      t.string :name
      t.integer :created_by

      t.timestamps
    end
    add_foreign_key :posts, :trips , column: :trip_id
    add_foreign_key :posts, :users , column: :created_by
  end
end
