class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :country
      t.integer :trip_id
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
    add_foreign_key :locations, :cities , column: :city_id
    add_foreign_key :cities, :trips , column: :trip_id
  end
end
