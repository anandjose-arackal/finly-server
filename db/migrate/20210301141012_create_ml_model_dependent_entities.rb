class CreateMlModelDependentEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :ml_model_dependent_entities do |t|
      t.integer :company_id, references: 'companies', null: false, index: true, foreign_key: true
      t.integer :ml_model_id, references: 'ml_models', null: false, index: true, foreign_key: true
      t.string :form_id, references: 'forms', null: false, index: true, foreign_key: true
      t.string :dependent_entity_id, references: 'form_entities', null: false, index: true, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
