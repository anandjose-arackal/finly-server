class Masters::PurchaseOrderStatuses::Resolver < Resolver::API

  entity PurchaseOrderStatus

  def load(params)
    excluded_invoice_ids = [ ]
    # ["saved", "released", "invoice_created", "received", "change_order", "cancelled", "closed", "open", "retracted", "processing", "approved", "rejected", "auto_approved", "sent_to_vendor", "voided", "po_revised", "vendor_confirmed", "vendor_rejected"]
    
    #   PurchaseOrderStatus.id_for(:vendor_created),
    #   PurchaseOrderStatus.id_for(:vendor_sent),
    #   PurchaseOrderStatus.id_for(:client_rejected),
    #   PurchaseOrderStatus.id_for(:client_accepted) 
    # ]

    PurchaseOrderStatus.where.not(id: excluded_invoice_ids)
  end

end