class AddCoverPictureToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cover_picture_id, :string
    add_column :users, :cover_picture_filename, :string
    add_column :users, :cover_picture_size, :integer
  end
end
