class CreateFieldParentMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :field_parent_mappings do |t|
      t.references :field_configuration, index: true, foreign_key: true, null: false
      t.references :field_parent_type, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    FieldConfiguration.all.each do |field_configuration|
      mapping = field_configuration.field_parent_mappings.build field_parent_type_id: field_configuration.field_parent_type_id
      mapping.save
    end
  end
end
