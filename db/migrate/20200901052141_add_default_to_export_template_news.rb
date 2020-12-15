class AddDefaultToExportTemplateNews < ActiveRecord::Migration[5.2]
  def change
    add_column :export_template_news, :default, :boolean, default: false, index: true
  end
end
