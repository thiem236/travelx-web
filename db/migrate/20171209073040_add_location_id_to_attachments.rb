class AddLocationIdToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :location_id, :integer
    add_foreign_key :attachments, :locations , column: :location_id

  end
end
