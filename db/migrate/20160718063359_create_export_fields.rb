class CreateExportFields < ActiveRecord::Migration
  def change
    create_table :export_fields do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
