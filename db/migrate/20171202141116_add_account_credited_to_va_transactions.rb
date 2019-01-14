class AddAccountCreditedToVaTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_account_transactions, :receiving_account_credited, :boolean
    NotifierType.seed_data
  end
end
