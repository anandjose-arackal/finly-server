class AddBeneficiaryDetailsToBankPaymentRequestComments < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_request_comments, :beneficiary_id, :integer, references: "BankAccount", foreign_key: true, index: true
  end
end
