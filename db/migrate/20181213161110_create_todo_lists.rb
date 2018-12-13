class CreateTodoLists < ActiveRecord::Migration[5.1]
  def change
    create_table :todo_lists do |t|
      t.string :todo
      t.integer :trip_id
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :long, precision: 10, scale: 6
      t.date :create_date
      t.integer :is_delete
      t.string   :status
	  t.timestamps
    end
	add_foreign_key :todo_lists, :trips, column: :trip_id
  end
  
end
