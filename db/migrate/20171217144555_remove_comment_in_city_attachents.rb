class RemoveCommentInCityAttachents < ActiveRecord::Migration[5.1]
  def change
    remove_column :cities, :comments
    remove_column :attachments, :comments
  end
end
