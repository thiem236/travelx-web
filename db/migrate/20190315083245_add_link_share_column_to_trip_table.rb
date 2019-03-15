class AddLinkShareColumnToTripTable < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :link_share, :string
  end
end
