class ExportManager::Template::Master::PurchaseRequests::Index < ExportManager::Builders::Template
  attr_accessor :input_data

  label 'Spreadsheet'
  description 'Purchase Requests Export'
  export_format 'xls'
  resource 'purchase_requests'
  subscribe 'purchase_requests'
  default true

  attribute :request_id, template: '{{ record.request_id }}'
  attribute :description, template: '{{ record.description }}'
  attribute :department, template: '{{ record.department.name }}'
  attribute :location, template: '{{ record.location.name }}'
  attribute :policy, template: '{{ record.policy.name }}'
  attribute :total_items, template: '{{ record.items.count }}'
  attribute :created_by, template: '{{ record.created_by.name }}'
  attribute :status, template: '{{ record.status.name }}'
  attribute :amount, template: '{{ record.total_amount.value }}'
end