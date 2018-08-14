class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.string :file_id
      t.string :file_filename
      t.string :file_content_type
      t.string :place
      t.integer :peoples, array: true
      t.jsonb :likes
      t.string :able_type
      t.integer :able_id
      t.string :caption
      t.decimal :lat, precision: 11, scale: 7
      t.decimal :long, precision: 11, scale: 7

      t.timestamps
    end
  end
end
