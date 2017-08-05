class MakeBankAccountsPolymorphic < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :account_owner_id, :integer
    add_column :bank_accounts, :account_owner_type, :string
  end
end
