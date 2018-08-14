class AddLikeCommentsToAttachments < ActiveRecord::Migration[5.1]
  def change
    remove_column :attachments, :likes
    add_column :attachments, :likes, :integer, array: true, default: []
    add_column :attachments, :comments, :jsonb, default: []
  end
end
