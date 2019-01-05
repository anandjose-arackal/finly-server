class ChangeColumnNamesInVirtualBankAccountrs < ActiveRecord::Migration[4.2]
  def change
    rename_column :virtual_bank_accounts, :date_after, :active_after
    rename_column :virtual_bank_accounts, :date_on, :active_on
  end
end
