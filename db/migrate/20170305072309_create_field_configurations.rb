class CreateFieldConfigurations < ActiveRecord::Migration
  def change
    create_table :field_configurations do |t|
      t.boolean :enabled, null: false, default: true
      t.references :field_type, index: true, foreign_key: true, null: false
      t.boolean :mandatory, null: false, default: false
      t.references :company, index: true, foreign_key: true, null: false
      t.references :field_parent_type, index: true, foreign_key: true, null: false
      t.integer :configurable_id, index: true, null: false
      t.string :configurable_type, index: true, null: false
      t.text :default_value

      t.timestamps null: false
    end
  end
end
