class AddNameToVirtualBankAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :name, :string
  end
end