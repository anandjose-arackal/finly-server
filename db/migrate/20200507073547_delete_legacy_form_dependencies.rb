class DeleteLegacyFormDependencies < ActiveRecord::Migration[5.2]
  def change
    drop_table :form_dependencies
    drop_table :form_dependency_mappings
    drop_table :form_dependency_choice_mappings
  end
end
