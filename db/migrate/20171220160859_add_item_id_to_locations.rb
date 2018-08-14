class AddItemIdToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :item_id, :string
  end
end
