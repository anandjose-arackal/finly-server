class AddVirtualBankAccountToInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :virtual_account_id, :integer, references: "VirtualBankAccount", foreign_key: true, index: true
  end
end
