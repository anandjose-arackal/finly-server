class CreateCustomFields < ActiveRecord::Migration[4.2]
  def change
    create_table :custom_fields do |t|
      t.references :field_configuration, index: true, foreign_key: true, null: false
      t.text :value
      t.integer :parent_id, index: true, null: false
      t.string :parent_type, index: true, null: false

      t.timestamps null: false
    end
  end
end
