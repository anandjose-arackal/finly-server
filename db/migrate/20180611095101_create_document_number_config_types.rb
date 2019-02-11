class CreateDocumentNumberConfigTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :document_number_config_types do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
