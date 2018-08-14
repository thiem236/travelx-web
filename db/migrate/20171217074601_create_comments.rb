class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :comment_able_id
      t.string :comment_able_type
      t.text :content

      t.timestamps
    end
  end
end
