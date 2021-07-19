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
  attribute :created_by, template: '{{ record.purchase_request.created_by.name }}'
  attribute :purchase_request_status, template: '{{ record.purchase_request.status.name }}'
  attribute :amount, template: '{{ record.purchase_request.total_amount.value }}'

  attribute :item_description, template: '{{ record.item.description }}'
  attribute :item_code, template: '{{ record.item.item_number }}'
  attribute :preferred_vendor_name, template: '{{ record.vendor.business_name }}'
  attribute :cost_center, template: '{{ record.cost_center.name }}'
  attribute :required_by_date, template: '{{ record.required_by_date }}'
  attribute :category, template: '{{ record.category.name }}'
  attribute :department_name, template: '{{ record.department.name }}'
  attribute :delivery_location_name,  template: '{{ record.delivery_location.name }}'
  attribute :purpose, template: '{{ record.purpose }}'
  attribute :item_quantity, template: '{{ record.quantity }}'
  attribute :item_status, template: '{{ record.status.name }}'
  attribute :estimated_unit_price, template: '{{ record.estimated_amount.value }}'

end