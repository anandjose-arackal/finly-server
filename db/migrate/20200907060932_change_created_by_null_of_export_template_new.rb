class ChangeCreatedByNullOfExportTemplateNew < ActiveRecord::Migration[5.2]
  def change
    change_column_null :export_template_news, :created_by_id, true
  end
end
