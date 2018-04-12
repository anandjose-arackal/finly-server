class AddOutwardInvoiceTypeIdToOutwardInvoice < ActiveRecord::Migration
  def change
    add_reference :outward_invoices, :outward_invoice_type, index: true, foreign_key: true, default: OutwardInvoiceType.id_for(:tax_invoice)
  end
end
