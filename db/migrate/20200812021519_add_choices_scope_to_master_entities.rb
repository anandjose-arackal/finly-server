class AddChoicesScopeToMasterEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :master_entities, :choices_scope, :text
  end
end
