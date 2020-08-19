class CreateFormCustomFieldAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :form_custom_field_attachments do |t|
      t.attachment :attachment
    end
  end
end
