class AddBalanceAndTdsAmountToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
  	add_column :beneficiary_payments, :tds_amount_id, :integer, references: "Amount", foreign_key: true
  	add_column :beneficiary_payments, :balance_due_id, :integer, references: "Amount", foreign_key: true
  	add_column :beneficiary_payments, :net_amount_id, :integer, references: "Amount", foreign_key: true
  end
end
