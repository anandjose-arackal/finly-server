class CreateExportConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :export_configs do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.references :export_config_type, index: true, foreign_key: true, null: false
      t.references :field_reference, polymorphic: true
      t.integer :order
      t.string :field_name
      t.boolean :spreadsheet, default: true
      t.boolean :pdf, default: true

      t.timestamps null: false
    end
  end
end
