class AddBeneficiaryTypeToBankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :beneficiary_type_id, :integer
  end
end
