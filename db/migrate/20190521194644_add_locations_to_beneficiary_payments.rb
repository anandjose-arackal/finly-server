class AddLocationsToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :location_id, :integer
    add_column :beneficiary_payments, :vendor_location_id, :integer
  end
end
