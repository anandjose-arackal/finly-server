class AddFieldParentTypeToFieldConfiguration < ActiveRecord::Migration
  def change
    add_column :field_configurations, :field_parent_type_id, :integer, references: "FieldParentType", foreign_key: true, index: true
  end
end
