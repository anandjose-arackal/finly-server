class RemoveNotNullFormEntityValidation < ActiveRecord::Migration[5.2]
  def change
    change_column_null :form_entity_validations, :form_entity_id, true
  end
end
