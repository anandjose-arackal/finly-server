class RenameScopeToChoicesConfig < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_entities, :scope, :choices_provider
  end
end
