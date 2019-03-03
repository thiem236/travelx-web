class ChangeTypeForColumnStatusOfTodoList < ActiveRecord::Migration[5.1]
  def change
    change_column :todo_lists, :status, 'boolean USING CAST(status AS boolean)'
  end
end
