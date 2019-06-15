class CreateDocumentMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :document_messages do |t|
      t.integer :order, index: true
      t.integer :user_id, foreign_key: true, references: 'users', index: true
      t.integer :type_id, foreign_key: true, references: 'document_chat_types', index: true
      t.text :body
      t.attachment :attachment
      t.datetime :deleted_at, index: true
      t.datetime :trashed_at, index: true
      t.integer :messageable_document_id, index: true, null: false
      t.string :messageable_document_type, index: true, null: false

      t.timestamps
    end
  end
end
