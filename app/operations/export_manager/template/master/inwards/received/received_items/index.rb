class ExportManager::Template::Master::Inwards::Received::ReceivedItems::Index < ExportManager::Builders::Template

  label 'Spreadsheet (Line Items)'
  description 'Receipt Note Export (Line Items)'
  export_format 'xls'
  resource 'receipt_note_items'
  subscribe 'receipt_note_items'
  default true

  attribute :receipt_note_number, template: '{{ record.inward_document.receipt_note_number }}'
  attribute :delivery_date, template: '{{ record.inward_document.delivery_date }}'
  attribute :document_number, template: '{{ record.inward_document.doc_number }}'
  attribute :po_number, template: ' {{ record.inward_document.purchase_order.po_number }} '
  attribute :vendor_name, template: '{{ record.inward_document.vendor.display_name }}'
  attribute :vendor_business_name, template: '{{ record.inward_document.vendor.business_name }}'
  attribute :vendor_mobile_number, template: ' {{ record.description }} '
  attribute :quantity, template: '{{ record.quantity }}'
  attribute :delivered, template: '{{ record.delivered }}'
  attribute :rejected, template: ' {{record.rejected}} '
  attribute :rejected, template: '{{ record.rejected }}'
  attribute :billable_amount, template: '{{ record.billable_amount}}'

end