class AddSequenceAndPrefixToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :sequence_start, :string
    add_column :outward_invoices, :prefix, :string
  end
end