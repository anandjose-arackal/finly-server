class RenameParentToParentRecordInMlModels < ActiveRecord::Migration[6.0]
  def change
    remove_column :ml_models, :parent_id
    remove_column :ml_models, :parent_type
    add_column :ml_models, :parent_id, :string, index: true
    add_column :ml_models, :parent_type, :string, index: true
    add_index :ml_models, [:parent_type, :parent_id]
  end
end
