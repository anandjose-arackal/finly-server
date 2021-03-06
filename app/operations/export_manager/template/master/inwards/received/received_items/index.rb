class ExportManager::Template::Master::Inwards::Received::ReceivedItems::Index < ExportManager::Builders::Template

  label 'Spreadsheet Receipt Note(Line Items)'
  description 'Receipt Note  (Line Items)'
  export_format 'xls'
  resource 'receipt_note_items'
  subscribe 'receipt_note_items'
  default true

  attribute :reference_number, template: '{{ record.inward_document.receipt_note_number }}'
  attribute :grn_number, template: '{{ record.inward_document.grn_number}}'
  attribute :delivery_date, template: '{{ record.inward_document.delivery_date }}'
  attribute :po_number, template: ' {{ record.inward_document.purchase_order.po_number }} '
  attribute :receipt_note_added_by, template: '{{ record.inward_document.user.name }}'
  attribute :vendor_name, template: '{{ record.inward_document.vendor.display_name }}'
  attribute :vendor_business_name, template: '{{ record.inward_document.vendor.business_name }}'
  attribute :vendor_code , template: '{{ record.inward_document.vendor.vendor_id }}'
  attribute :description, template:  '{{ record.description }}'
  attribute :quantity, template: '{{ record.quantity }}'
  attribute :delivered, template: '{{ record.delivered }}'
  attribute :rejected, template: ' {{record.rejected}} '
  attribute :rejected, template: '{{ record.rejected }}'
  attribute :billable_amount, template: '{{ record.billable_amount}}'
  attribute :previously_billed_amount, template: '{{  record.previously_billed_amount }}'
  attribute :product_type, template: '{{ record.product_type }}'
  attribute :comment, template: '{{ record.comment}}'
end