class UpdateFieldParentTypeNonmandatory < ActiveRecord::Migration[4.2]
  def change
    change_column_null :field_configurations, :field_parent_type_id, false
    remove_foreign_key :field_configurations, :field_parent_type
    remove_index :field_configurations, :field_parent_type_id
    remove_column :field_configurations, :field_parent_type_id
  end
end
