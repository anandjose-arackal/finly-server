class AddAdvanceAmountIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :advance_amount_id, :integer, references: 'Amount', foreign_key: true
    add_index :beneficiary_payments, :advance_amount_id
  end
end
