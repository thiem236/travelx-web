class AddStartDateEndDateToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :start_date, :bigint
    add_column :locations, :end_date, :bigint
  end
end
