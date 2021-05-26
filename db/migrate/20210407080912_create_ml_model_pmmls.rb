class CreateMlModelPmmls < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      MlModel.update_all(pmml: nil)
    end
    remove_column :ml_models, :pmml
    create_table :ml_model_pmmls do |t|
      t.integer :company_id, references: 'companies', null: false, index: true, foreign_key: true
      t.integer :ml_model_id, references: 'ml_models', null: false, index: true, foreign_key: true
      t.text :pmml, limit: 4294967295
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
