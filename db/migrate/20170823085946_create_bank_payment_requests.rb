class CreateBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_payment_requests do |t|
      t.integer :owner_id, references: "User", foreign_key: true, index: true
      t.integer :status_id, references: "BankPaymentRequestAction", foreign_key: true, index: true
      t.integer :controlling_user_id, references: "User", foreign_key: true, index: true
      t.references :payment_order
      t.string :name
      t.integer :requested_amount_id, references: "Amount", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
