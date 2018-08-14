class AddLatLongToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :lat, :decimal, precision: 10, scale: 6
    add_column :posts, :long, :decimal, precision: 10, scale: 6
  end
end
