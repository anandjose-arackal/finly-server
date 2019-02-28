class AddCostCenterToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :cost_center_id, :integer, references: 'CostCenter', foreign_key: true
    add_index :beneficiary_payments, :cost_center_id
  end
end
