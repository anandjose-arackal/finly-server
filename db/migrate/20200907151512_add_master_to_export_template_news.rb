class AddMasterToExportTemplateNews < ActiveRecord::Migration[5.2]
  def change
    add_column :export_template_news, :master, :string
  end
end
