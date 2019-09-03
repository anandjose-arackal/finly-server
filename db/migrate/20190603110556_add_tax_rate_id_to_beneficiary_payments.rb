class AddTaxRateIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :tax_rate_id, :integer
  end
end
