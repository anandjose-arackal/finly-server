class AddNameToVirtualBankAccount < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :name, :string
  end
end