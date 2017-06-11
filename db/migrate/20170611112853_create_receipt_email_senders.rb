class CreateReceiptEmailSenders < ActiveRecord::Migration
  def change
    create_table :receipt_email_senders do |t|
      t.string :email_id, null: false
      t.string :domain, null: false
      t.string :search_term, null: false
      t.references :receipt_email_template, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
