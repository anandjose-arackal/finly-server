class AddPaymentAgreementIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :payment_agreement_id, :integer
  end
end
