class CreateUserTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :user_trips do |t|
      t.references :user
      t.references :trip

      t.timestamps
    end
    add_foreign_key :user_trips, :trips , column: :trip_id
    add_foreign_key :user_trips, :users , column: :user_id
  end
end
