class ChangeReceivingAccountTypeFromIntegerToString < ActiveRecord::Migration[4.2]
  def change
    change_column :invoices, :receiving_account_type, :string
  end
end
