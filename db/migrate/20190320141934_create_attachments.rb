class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.integer :resource_id
      t.string :resource_type
      t.string :attachment_file_name
      t.decimal :attachment_file_size, precision: 64, scale: 12
      t.string :attachment_content_type
      t.datetime :attachment_updated_at
      t.integer :company_id
      t.integer :creator_id

      t.timestamps
    end
  end
end
