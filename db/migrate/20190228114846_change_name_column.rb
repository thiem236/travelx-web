class ChangeNameColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :todo_lists, :form_date, :from_date
  end
end