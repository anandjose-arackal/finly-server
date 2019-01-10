class AddSequenceAndPrefixToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :sequence_start, :string
    add_column :outward_invoices, :prefix, :string
  end
end