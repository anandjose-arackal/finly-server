class AddPivotToMlModels < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_models, :pivot_keys, :string
    add_column :ml_model_pmmls, :pivot, :string, index: true
    add_index :ml_model_pmmls, [:pivot, :company_id, :ml_model_id], unique: true
    
    # This is to facilitate upsert logic
    ActsAsTenant.without_tenant do
      MlModelPrediction.unscoped.delete_all
      MlModelPmml.unscoped.delete_all
      MlModel.unscoped.delete_all
    end
    add_index :ml_model_predictions, [:record_id, :record_type, :ml_model_id], unique: true, name: "index_ml_model_predictions_on_record_and_ml_model_id"

    ActsAsTenant.without_tenant do
      MlModel::Monitor.seed_data
    end
  end
end
