class Docs::P2P::Invoices::Agreement::Resolver < Docs::P2P::Invoices::Resolver

  def load(params)
    invoices = super(params)
    type_id = InwardInvoiceType.ids_for(:general_invoice, :rental_invoice, :recurring_invoice, :agreement_invoice)
    invoices.where(invoice_type_id: type_id)
  end


end