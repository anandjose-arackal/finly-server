class CreateDropDownItemFieldConfigurationMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :parent_dependent_field_configuration_mappings do |t|
      t.integer :parent_id, polymorphic: true
      t.string :parent_type, polymorphic: true
      t.integer :dependent_field_configuration_id, references: "FieldConfiguration", foreign_key: true

      t.timestamps null: false
    end
  end
end