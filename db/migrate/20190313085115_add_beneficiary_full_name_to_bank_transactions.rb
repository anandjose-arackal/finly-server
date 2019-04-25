class AddBeneficiaryFullNameToBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_transactions, :beneficiary_full_name, :string
  end
end
