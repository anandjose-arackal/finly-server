class RemoveNotNullFormConditionActions < ActiveRecord::Migration[6.0]
  def change
    change_column_null :form_condition_actions, :form_condition_id, true
  end
end
