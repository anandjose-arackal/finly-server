class AddIterFieldToExportTemplateNew < ActiveRecord::Migration[6.0]
  def change
    add_column :export_template_news, :iter_field, :text, limit: 4294967295
  end
end
