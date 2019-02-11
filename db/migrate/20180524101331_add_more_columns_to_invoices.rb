class AddMoreColumnsToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :receiving_account_id, :integer, polymorphic: true, foreign_key: true, index: true
    add_column :invoices, :receiving_account_type, :integer, polymorphic: true
  end
end
