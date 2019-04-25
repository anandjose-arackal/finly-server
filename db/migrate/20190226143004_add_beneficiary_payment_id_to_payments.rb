class AddBeneficiaryPaymentIdToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :beneficiary_payment_id, :integer, references: 'BeneficiaryPayment', foreign_key: true
    add_index :payments, :beneficiary_payment_id
  end
end
