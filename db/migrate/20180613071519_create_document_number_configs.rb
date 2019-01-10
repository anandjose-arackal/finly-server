class CreateDocumentNumberConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :document_number_configs do |t|
      t.string :prefix
      t.string :sequence_start
      t.references :company, index: true, foreign_key: true
      t.references :document_number_config_type, index: true, foreign_key: true
      t.references :purpose, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
