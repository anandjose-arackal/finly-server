class CreateDocumentMessageReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :document_message_receipts do |t|
      t.integer :user_id, foreign_key: true, references: 'users', index: true, null: false
      t.integer :receiptable_document_id, index: true, null: false
      t.string :receiptable_document_type, index: true, null: false
      t.integer :document_message_id, foreign_key: true, index: true, references: 'document_messages', null: false
      t.datetime :browser_push_sent_at, index: true
      t.datetime :app_push_sent_at, index: true
      t.datetime :email_sent_at, index: true
      t.datetime :read_at, index: true
      t.datetime :trashed_at, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
