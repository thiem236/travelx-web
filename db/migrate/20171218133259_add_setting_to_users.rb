class AddSettingToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :setting, :jsonb
  end
end
