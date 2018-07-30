class ChangeReceivingAccountTypeFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :invoices, :receiving_account_type, :string
  end
end
