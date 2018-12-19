class AddFormDateToDateToTodoList < ActiveRecord::Migration[5.1]
  def change
    add_column :todo_lists, :form_date, :date
    add_column :todo_lists, :to_date, :date
  end
end
