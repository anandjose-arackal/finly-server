class CreateCustomExportConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :custom_export_configurations do |t|
      t.references :configurable, polymorphic: true
      t.boolean :custom_report
      t.boolean :custom_invoice
      t.boolean :custom_purchase_order

      t.timestamps null: false
    end
  end
end
