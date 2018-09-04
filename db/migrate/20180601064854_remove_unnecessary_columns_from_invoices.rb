class RemoveUnnecessaryColumnsFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :sgst_amount_id, :integer
    remove_column :invoices, :csgt_amount_id, :integer
    remove_column :invoices, :igst_amount_id, :integer
  end
end
