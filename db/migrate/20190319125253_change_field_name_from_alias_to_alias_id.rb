class ChangeFieldNameFromAliasToAliasId < ActiveRecord::Migration[5.2]
  def change
    rename_column :icici_bank_configs, :alias, :alias_id
  end
end
