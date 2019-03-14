class AddStatusIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :status_id, :integer, references: "BeneficiaryPaymentStatus", foreign_key: true
    add_index :beneficiary_payments, :status_id
  end
end
