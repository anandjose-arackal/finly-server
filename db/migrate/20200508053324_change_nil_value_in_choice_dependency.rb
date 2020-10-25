class ChangeNilValueInChoiceDependency < ActiveRecord::Migration[5.2]
  def change
    change_column_null :form_rules, :match_entity_path, true
  end
end
