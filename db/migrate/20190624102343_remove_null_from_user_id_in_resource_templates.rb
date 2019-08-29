class RemoveNullFromUserIdInResourceTemplates < ActiveRecord::Migration[5.2]
  def change
    change_column_null :resource_templates, :user_id, true
  end
end
