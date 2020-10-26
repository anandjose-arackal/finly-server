class RemoveNotNullFormDependencyConfig < ActiveRecord::Migration[5.2]
  def change
    change_column_null :form_choice_dependency_mappings, :dependency_id, true
  end
end
