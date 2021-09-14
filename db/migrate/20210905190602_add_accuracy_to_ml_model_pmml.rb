class AddAccuracyToMlModelPmml < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_model_pmmls, :accuracy, :float, index: true, default: 0
    add_column :ml_model_predictions, :ml_model_pmml_id, :integer, index: true, foreign_key: true, references: 'ml_model_pmmls'
    add_index :ml_model_predictions, [:record_id, :record_type, :ml_model_id, :ml_model_pmml_id], unique: true, name: "index_ml_model_predictions_on_record_and_ml_model"
    add_column :ml_model_pmmls, :predicted_records, :integer, index: true, default: 0
  end
end
