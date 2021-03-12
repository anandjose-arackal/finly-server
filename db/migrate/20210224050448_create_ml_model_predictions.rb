class CreateMlModelPredictions < ActiveRecord::Migration[6.0]
  def change
    create_table :ml_model_predictions do |t|
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.references :ml_model, foreign_key: true, index: true
      t.references :record, polymorphic: true, index: true
      t.string :actual_value
      t.string :predicted_value
      t.boolean :is_accurate_prediction

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
