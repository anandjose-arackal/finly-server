class RenameBeneficiaryAccountNo < ActiveRecord::Migration
  def change
    add_column :virtual_account_transactions, :beneficiary_account_no, :string, index: true
    remove_column :virtual_account_transactions, :beneficiary_account_number
  end
end
