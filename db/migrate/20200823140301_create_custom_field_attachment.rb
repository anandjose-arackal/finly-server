class CreateCustomFieldAttachment < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_field_attachments do |t|
      t.uuid :uuid
      t.string :form_custom_field_id, index: true, foreign_key: true
      t.attachment :attachment
      t.datetime :deleted_at, index: true
    end
  end
end
