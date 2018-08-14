class AddUploadByToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :upload_by, :integer
  end
end
