class ExportManager::Template::Master::PurchaseRequests::PurchaseRequestItems::Index < ExportManager::Builders::Template

  label 'Purchase Request (Line Items)'
  description 'Purchase Request Export (Line Items)'
  export_format 'xls'
  resource 'purchase_request_items'
  subscribe 'purchase_request_items'
  default true

  attribute :request_id, template: '{{ record.purchase_request.request_id }}'
  attribute :request_description, template: '{{ record.purchase_request.description }}'
  attribute :policy, template: '{{ record.purchase_request.policy.name }}'
  attribute :created_by, template: '{{ record..purchase_requestcreated_by.name }}'
  attribute :purchase_request_status, template: '{{ record.purchase_request.status.name }}'
  attribute :amount, template: '{{ record.purchase_request.total_amount.value }}'

  attribute :item_description, template: '{{}}'
  attribute :item_code, template: ''
  attribute :preferred_vendor_name, template: ''
  attribute :cost_center, template: ' '
  attribute :required_by_date, template: ''
  attribute :category, template: ''
  attribute :delivery_location_name,  template: ''
  attribute :purpose, template: ' '
  attribute :item_quantity, template: '{{}}'
  attribute :estimated_unit_price, template: ''
  attribute :item_status, template: ''
  attribute :department_name, template: ''


end