class AddLocationToAttachemts < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :place_id, :string
    add_column :attachments, :place_type, :string
  end
end
