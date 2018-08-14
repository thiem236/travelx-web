class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.string :name
      t.text :description
      t.jsonb :trip_schedule
      t.string :cover_picture_id
      t.string :cover_picture_filename
      t.integer :cover_picture_size
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :long, precision: 10, scale: 6
      t.integer :created_by
      t.bigint :start_date
      t.bigint :end_date

      t.timestamps
      t.index :trip_schedule, using: :gin
    end
    add_foreign_key :trips, :users,  column: :created_by

  end
end
