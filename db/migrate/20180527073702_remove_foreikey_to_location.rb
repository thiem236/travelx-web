class RemoveForeikeyToLocation < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :locations, column: :city_id
    remove_foreign_key :locations, column: :trip_id
    remove_foreign_key :attachments, column: :location_id
  end
end
