class AddConfigPathToEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :form_entities, :config_path, :string, index: true
  end
end
