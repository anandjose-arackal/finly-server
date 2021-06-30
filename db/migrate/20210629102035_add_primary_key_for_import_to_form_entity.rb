class AddPrimaryKeyForImportToFormEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :primary_key_for_import, :string
  end
end
