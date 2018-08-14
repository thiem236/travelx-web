class AddUploadedAtToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :uploaded_at, :bigint
  end
end
