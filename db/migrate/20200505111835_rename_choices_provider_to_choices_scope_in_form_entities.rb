class RenameChoicesProviderToChoicesScopeInFormEntities < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_entities, :choices_provider, :choices_scope
  end
end
