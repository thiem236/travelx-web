class RemoveForeignKeyStamps < ActiveRecord::Migration[5.1]
  def change
    remove_index :stamps, [:country, :user_id]
    add_column :stamps, :uploaded_at, :integer
  end
end
