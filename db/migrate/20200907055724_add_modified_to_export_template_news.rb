class AddModifiedToExportTemplateNews < ActiveRecord::Migration[5.2]
  def change
    add_column :export_template_news, :modified, :boolean, default: false, index: true
  end
end
