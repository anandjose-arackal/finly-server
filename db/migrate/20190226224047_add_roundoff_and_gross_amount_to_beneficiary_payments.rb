class AddRoundoffAndGrossAmountToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :gross_amount_id, :integer, references: 'Amount', foreign_key: true
    add_column :beneficiary_payments, :roundoff_amount, :decimal
  end
end
