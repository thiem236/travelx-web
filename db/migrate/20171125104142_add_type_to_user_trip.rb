class AddTypeToUserTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :user_trips, :user_type, :string
  end
end
