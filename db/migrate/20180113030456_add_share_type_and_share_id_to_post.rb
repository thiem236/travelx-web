class AddShareTypeAndShareIdToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :activity_type, :string
    add_column :posts, :activity_id, :integer
    add_column :posts, :obj, :jsonb
    remove_column :posts, :content, :text
    rename_column :posts, :name, :title
    add_column :posts, :total_comment, :integer
    add_column :posts, :total_like, :integer
    add_column :posts, :likes, :integer, array: true
    remove_foreign_key :posts, :trips
    remove_column :posts, :trip_id,:integer
  end
end
