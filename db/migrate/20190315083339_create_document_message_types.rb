class CreateDocumentMessageTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :document_message_types do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    DocumentMessageType.seed_data
  end
end
