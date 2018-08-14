class AddStampIdsToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :stamp_ids, :integer, array: :true
  end
end
