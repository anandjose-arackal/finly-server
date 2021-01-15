class CreateExportResources < ActiveRecord::Migration[5.2]
  def change
    create_table :export_resources do |t|
      t.string :name
      t.string :value
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
