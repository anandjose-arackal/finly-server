class AddHideInImportFormInFormEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :hide_in_import, :boolean
  end
end
