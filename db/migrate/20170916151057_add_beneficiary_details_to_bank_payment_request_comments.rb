class AddBeneficiaryDetailsToBankPaymentRequestComments < ActiveRecord::Migration
  def change
    add_column :bank_payment_request_comments, :beneficiary_id, :integer, references: "BankAccount", foreign_key: true, index: true
  end
end
