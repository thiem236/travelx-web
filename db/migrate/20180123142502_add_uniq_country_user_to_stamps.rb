class AddUniqCountryUserToStamps < ActiveRecord::Migration[5.1]
  def change
    add_index :stamps, [:country, :user_id], :unique => true
  end
end
