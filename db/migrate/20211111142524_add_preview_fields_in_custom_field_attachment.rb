class AddPreviewFieldsInCustomFieldAttachment < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_field_attachments, :pdf_preview_file_name,     :string
    add_column :custom_field_attachments, :pdf_preview_file_size,     :integer
    add_column :custom_field_attachments, :pdf_preview_content_type,  :string
    add_column :custom_field_attachments, :pdf_preview_updated_at,    :datetime
  end
end
