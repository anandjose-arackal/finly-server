class ExportManager::Template::Master::PurchaseRequests::Index < ExportManager::Builders::Template
  attr_accessor :input_data

  label 'Spreadsheet'
  description 'Purchase Requests Export'
  export_format 'xls'
  resource 'purchase_requests'
  subscribe 'purchase_requests'
  default true

  custom_fields :purchase_request, template_prefix: 'record'
  
  attribute :request_id, template: '{{ record.request_id }}'
  attribute :description, template: '{{ record.description }}'
  attribute :department, template: '{{ record.department.name }}'
  attribute :location, template: '{{ record.location.name }}'
  attribute :policy, template: '{{ record.policy.name }}'
  attribute :approval_pending_level_number, template: '{{ record.controlling_level.level_number }}'
  attribute :approval_pending_level_name, template: '{{ record.controlling_level.name }}'
  attribute :approval_pending_reviewers, template: '{{ record.get_reviewers_names }}'
  attribute :approved_reviewers, template: '{{ record.approved_reviewers_names }}'
  attribute :total_items, template: '{{ record.items.count }}'
  attribute :created_by, template: '{{ record.created_by.name }}'
  attribute :status, template: '{{ record.status.name }}'
  attribute :amount, template: '{{ record.total_amount.value }}'

end