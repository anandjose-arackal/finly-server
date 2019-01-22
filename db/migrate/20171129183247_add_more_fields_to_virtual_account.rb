class AddMoreFieldsToVirtualAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :maximum_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :virtual_bank_accounts, :minimum_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :virtual_bank_accounts, :allowed_transaction_count, :integer
    add_column :virtual_bank_accounts, :neft, :boolean, default: true
    add_column :virtual_bank_accounts, :imps, :boolean, default: true
    add_column :virtual_bank_accounts, :rtgs, :boolean, default: true
    add_column :virtual_bank_accounts, :current_account, :boolean, default: true
    add_column :virtual_bank_accounts, :savings_account, :boolean, default: true
    add_column :virtual_bank_accounts, :upi, :boolean, default: true
    add_column :virtual_bank_accounts, :date_after, :date
    add_column :virtual_bank_accounts, :date_on, :date
  end
end
