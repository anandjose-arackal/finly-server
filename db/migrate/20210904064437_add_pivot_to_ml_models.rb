class AddPivotToMlModels < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_models, :pivot_keys, :string
    add_column :ml_model_pmmls, :pivot, :string, index: true
    add_index :ml_model_pmmls, [:pivot, :company_id], :unique => true
    
    # This is to facilitate upsert logic
    ActsAsTenant.without_tenant do
      MlModelPrediction.delete_all
    end
    add_index :ml_model_predictions, [:record_id, :record_type], :unique => true
  end
end
