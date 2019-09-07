class AddCreatorIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :creator_id, :integer
    add_index :beneficiary_payments, :creator_id
  end
end
