class AddPaymentRequestToComments < ActiveRecord::Migration
  def change
    add_column :bank_payment_request_comments, :bank_payment_request_id, :integer, references: "BankPaymentRequest", index: true, foreign_key: true
  end
end
