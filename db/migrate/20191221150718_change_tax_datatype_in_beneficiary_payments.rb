class ChangeTaxDatatypeInBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
  	change_column :beneficiary_payments, :tax, :decimal, precision: 10, scale: 3
  end
end
