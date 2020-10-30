class AddTimeStampsToFormCustomField < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :form_custom_fields, default: DateTime.now
    change_column_default :form_custom_fields, :created_at, nil
    change_column_default :form_custom_fields, :updated_at, nil

    add_timestamps :custom_field_selections, default: DateTime.now
    change_column_default :custom_field_selections, :created_at, nil
    change_column_default :custom_field_selections, :updated_at, nil

    add_timestamps :custom_field_attachments, default: DateTime.now
    change_column_default :custom_field_attachments, :created_at, nil
    change_column_default :custom_field_attachments, :updated_at, nil
  end
end
