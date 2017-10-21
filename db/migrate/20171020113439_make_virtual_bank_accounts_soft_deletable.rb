class MakeVirtualBankAccountsSoftDeletable < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :is_deleted, :boolean, default: false
  end
end
