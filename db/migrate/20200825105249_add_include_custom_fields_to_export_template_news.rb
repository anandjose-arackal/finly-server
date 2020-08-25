class AddIncludeCustomFieldsToExportTemplateNews < ActiveRecord::Migration[5.2]
  def change
    add_column :export_template_news, :include_custom_fields, :boolean, default: false
  end
end
