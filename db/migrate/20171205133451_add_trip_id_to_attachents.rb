class AddTripIdToAttachents < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :trip_id, :integer
    add_column :attachments, :type, :string
    add_foreign_key :attachments, :trips , column: :trip_id
  end
end
