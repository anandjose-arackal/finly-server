class CreateReceiptEmails < ActiveRecord::Migration
  def change
    create_table :receipt_emails do |t|
      t.string :subject
      t.text :body
      t.text :raw_text
      t.text :raw_html
      t.text :raw_headers
      t.datetime :sent_at
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :receipt_emails, :user_id
    add_reference :receipts, :receipt_email, index: true, foreign_key: true
  end
end
