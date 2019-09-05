class AddMoreColumnsToRentalInvoice < ActiveRecord::Migration[5.2]
  def change
      # t.integer :po_adjusted_advance
      # t.integer :po_advance
      # t.integer :po_prev_adjusted_advance
      # t.boolean :advance_amount_required
      # t.integer :proforma_invoice_id
      # t.integer :proforma_advance
      # t.decimal :total_proforma_advance
      add_column :general_invoices, :po_adjusted_advance, :integer
      add_column :general_invoices, :po_advance, :integer
      add_column :general_invoices, :po_prev_adjusted_advance, :integer
      add_column :general_invoices, :advance_amount_required, :boolean
      add_column :general_invoices, :proforma_invoice_id, :integer
      add_column :general_invoices, :proforma_advance, :integer
      add_column :general_invoices, :total_proforma_advance, :integer

      add_column :rental_invoices, :po_adjusted_advance, :integer
      add_column :rental_invoices, :po_advance, :integer
      add_column :rental_invoices, :po_prev_adjusted_advance, :integer
      add_column :rental_invoices, :advance_amount_required, :boolean
      add_column :rental_invoices, :proforma_invoice_id, :integer
      add_column :rental_invoices, :proforma_advance, :integer
      add_column :rental_invoices, :total_proforma_advance, :integer


  end
end
