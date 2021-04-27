class RenameInvoiceConvertionColumn < ActiveRecord::Migration[6.0]
  def change

    rename_column :invoice_line_items, :item_gross_amount_converted, :reporting_item_gross_amount
    rename_column :invoice_line_items, :item_discount_amount_converted, :reporting_item_discount_amount
    rename_column :invoice_line_items, :item_taxable_amount_converted, :reporting_item_taxable_amount
    rename_column :invoice_line_items, :item_tax_amount_converted, :reporting_item_tax_amount
    rename_column :invoice_line_items, :item_tds_amount_converted, :reporting_item_tds_amount
    rename_column :invoice_line_items, :item_net_amount_converted, :reporting_item_net_amount
    rename_column :invoice_line_items, :item_billable_amount_converted, :reporting_item_billable_amount
    rename_column :invoices, :invoice_gross_amount_converted, :reporting_invoice_gross_amount
    rename_column :invoices, :invoice_discount_amount_converted, :reporting_invoice_discount_amount
    rename_column :invoices, :invoice_taxable_amount_converted, :reporting_invoice_taxable_amount
    rename_column :invoices, :invoice_tax_amount_converted, :reporting_invoice_tax_amount
    rename_column :invoices, :invoice_tds_amount_converted, :reporting_invoice_tds_amount
    rename_column :invoices, :invoice_paid_outside_amount_converted, :reporting_invoice_paid_outside_amount
    rename_column :invoices, :invoice_freight_amount_converted, :reporting_invoice_freight_amount
    rename_column :invoices, :invoice_sub_total_amount_converted, :reporting_invoice_sub_total_amount
    rename_column :invoices, :invoice_roundoff_amount_converted, :reporting_invoice_roundoff_amount
    rename_column :invoices, :invoice_total_amount_converted, :reporting_invoice_total_amount
    rename_column :invoices, :invoice_balance_due_converted, :reporting_invoice_balance_due
    rename_column :invoices, :invoice_net_total_amount_converted, :reporting_invoice_net_total_amount
    rename_column :invoices, :invoice_advance_paid_amount_converted, :reporting_invoice_advance_paid_amount
    

    # removing extra column
    remove_column :invoices, :tax_type
    remove_column :invoices, :transactions_service_period_to
    remove_column :invoices, :transactions_service_period_form

  end
end
