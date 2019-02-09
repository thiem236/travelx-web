class AddCityToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :city, :string
    add_column :cities, :city, :string
  end
end
