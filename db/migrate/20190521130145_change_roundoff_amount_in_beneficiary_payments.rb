class ChangeRoundoffAmountInBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
  	change_column :beneficiary_payments, :roundoff_amount, :decimal, precision: 20, scale: 10
  end
end
