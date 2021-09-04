class AddPivotToMlModels < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_models, :pivot_keys, :string
    add_column :ml_model_pmmls, :pivot, :string, index: true
  end
end
