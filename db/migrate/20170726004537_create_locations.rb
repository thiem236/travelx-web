class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :type
      t.text :note
      t.integer :pemark
      t.integer :trip_id
      t.integer :city_id
      t.string :city_name
      t.integer :rate
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :long, precision: 10, scale: 6
      t.bigint :start_day
      t.bigint :end_day
      t.timestamps
    end
    add_foreign_key :locations, :trips , column: :trip_id
  end
end
