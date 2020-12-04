PaperTrail.config.enabled = true
PaperTrail.config.object_changes_adapter =  AuditTrail::ObjectChangeAdapter.new()

PaperTrail::Version.class_eval do
  after_create :set_document_number

  def set_document_number
    klass = self.item_type.constantize
    binding.pry
    object = klass.find self.item_id
    case self.item_type
    when "PurchaseOrder"
      self.document_number = object.po_number
    when "PurchaseOrderItem"
      self.document_number = object.purchase_order.po_number
    when  "Invoice"
      self.document_number = object.invoice_id
    when  "InvoiceLineItem"
      self.document_number = object.invoice.invoice_id
    when "PurchaseRequest"
      self.document_number = object.order_number
    when "PurchaseRequestItem"
      self.document_number = object.purchase_request.order_number
    when "YesBankVendor"
      self.document_number = object.vendor_id
    when  "BankAccount"
      self.document_number = object.account_owner.try(:vendor_id)
    when "GstinLocation"
      self.document_number = object.vendor.try(:vendor_id)
    end
    self.save
  end
end