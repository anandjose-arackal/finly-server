class Docs::P2P::Invoices::NonPo::Resolver < Docs::P2P::Invoices::Resolver

  def load(params)
    invoices = super(params)
    type_id = InwardInvoiceType.id_for(:non_po_invoice)
    invoices.where(invoice_type_id: type_id)
  end


end