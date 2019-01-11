class CreateBankPaymentRequestComments < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_payment_request_comments do |t|
      t.text :content
      t.integer :action_id, references: "BankPaymentRequestCommentAction", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
