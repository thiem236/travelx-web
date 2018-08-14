class AddLikeCommentToCities < ActiveRecord::Migration[5.1]
  def change
    add_column :cities, :like, :integer, array: true, default: []
    add_column :cities, :comments, :jsonb, default: []
  end
end
