class AddTotalLikeTotalCommentToTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :total_like, :integer
    add_column :trips, :total_comment, :integer
  end
end
