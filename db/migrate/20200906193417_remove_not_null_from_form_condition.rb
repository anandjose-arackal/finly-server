class RemoveNotNullFromFormCondition < ActiveRecord::Migration[5.2]
  def change
    change_column_null :form_conditions, :referencable_id, true
    change_column_null :form_conditions, :referencable_type, true
  end
end
