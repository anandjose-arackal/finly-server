class CreateExportConfigTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :export_config_types do |t|
      t.string :name, index: true, null: false

      t.timestamps null: false
    end
    ExportConfigType.seed_data
  end
end
