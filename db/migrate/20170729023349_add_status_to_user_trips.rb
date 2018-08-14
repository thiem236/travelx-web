class AddStatusToUserTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :user_trips, :status, :string
  end
end
