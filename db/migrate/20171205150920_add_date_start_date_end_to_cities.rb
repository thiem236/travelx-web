class AddDateStartDateEndToCities < ActiveRecord::Migration[5.1]
  def change
    add_column :cities, :start_date, :bigint
    add_column :cities, :end_date, :bigint
    add_column :cities, :user_id, :integer
    add_index :cities, [:trip_id, :country, :name], :unique => true
    add_foreign_key :cities, :users , column: :user_id

  end
end
