class AddUserMaySeeToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :user_may_see, :integer, array: true, default: []
  end
end
