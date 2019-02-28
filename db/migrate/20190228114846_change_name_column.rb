class ChangeNameColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :todo_lists, :form_data, :from_date
  end
end