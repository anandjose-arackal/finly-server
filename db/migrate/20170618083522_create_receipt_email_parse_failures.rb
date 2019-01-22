class CreateReceiptEmailParseFailures < ActiveRecord::Migration[4.2]
  def change
    create_table :receipt_email_parse_failures do |t|
      t.references :user, index: true, foreign_key: true
      t.string :subject
      t.datetime :sent_at
      t.attachment :body
      t.attachment :raw_text
      t.attachment :raw_html
      t.attachment :raw_header
      t.attachment :original_source
      t.string :email_id
      t.string :sender
      t.attachment :source
      t.boolean :fixed, default: false
      t.string :parsed_merchant
      t.string :parsed_amount_value
      t.integer :parsed_currency_id, index: true, foreign_key: true
      t.datetime :parsed_datetime
      t.text :parsed_note
      t.integer :parsed_category_id, index: true, foreign_key: true


      t.timestamps null: false
    end
  end
end
