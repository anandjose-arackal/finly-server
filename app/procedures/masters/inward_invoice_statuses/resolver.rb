class Masters::InwardInvoiceStatuses::Resolver < Resolver::API

  entity InwardInvoiceStatus

  def load(params)
    excluded_invoice_ids = [ 
      InwardInvoiceStatus.id_for(:vendor_created),
      InwardInvoiceStatus.id_for(:vendor_sent),
      InwardInvoiceStatus.id_for(:client_rejected),
      InwardInvoiceStatus.id_for(:client_accepted) 
    ]

    InwardInvoiceStatus.where.not(id: excluded_invoice_ids)
  end

end