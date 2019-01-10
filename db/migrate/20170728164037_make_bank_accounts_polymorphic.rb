class MakeBankAccountsPolymorphic < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :account_owner_id, :integer
    add_column :bank_accounts, :account_owner_type, :string
  end
end
