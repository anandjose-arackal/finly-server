class Masters::PurchaseRequestStatuses::Resolver < Resolver::API

  entity PurchaseRequestStatus

  def load(params)
    excluded_invoice_ids = []
    # excluded_invoice_ids = [ 
    #   PurchaseRequestStatus.id_for(:vendor_created),
    #   PurchaseRequestStatus.id_for(:vendor_sent),
    #   PurchaseRequestStatus.id_for(:client_rejected),
    #   PurchaseRequestStatus.id_for(:client_accepted) 
    # ]

    PurchaseRequestStatus.where.not(id: excluded_invoice_ids)
  end

end