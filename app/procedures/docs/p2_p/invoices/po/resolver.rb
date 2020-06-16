class Docs::P2P::Invoices::Po::Resolver < Docs::P2P::Invoices::Resolver

  def load(params)
    invoices = super(params)
    type_id = InwardInvoiceType.id_for(:tax_invoice)
    invoices.where(invoice_type_id: type_id)
  end


end