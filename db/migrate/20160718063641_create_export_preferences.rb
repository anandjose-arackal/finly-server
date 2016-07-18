class CreateExportPreferences < ActiveRecord::Migration
  def change
    create_table :export_preferences do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.references :export_field, index: true, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
