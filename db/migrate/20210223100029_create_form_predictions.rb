class CreateFormPredictions < ActiveRecord::Migration[6.0]
  def change
    create_table :ml_models do |t|
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.references :parent, polymorphic: true, index: true
      t.string :type, null: false, index: true
      t.text :config, limit: 4294967295
      t.datetime :built_at, index: true
      t.string :build_schedule # Weekly, Monthly, Daily
      t.string :track_schedule # Weekly, Monthly, Daily
      t.integer :build_duration
      t.datetime :tracked_at, index: true
      t.text :pmml, limit: 4294967295
      t.string :algorithm
      t.string :target_key, index: true, null: false
      t.string :target_key_type, index: true, null: false
      t.string :split_key, index: true
      t.string :split_key_type, index: true
      t.string :model_klass, index: true

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
