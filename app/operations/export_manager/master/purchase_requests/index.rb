class ExportManager::Master::PurchaseRequests::Index < ExportManager::Builders::Template
  attr_accessor :input_data

  label 'Spreadsheet'
  description 'Purchase Requests Export'
  export_format 'csv'
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

  # def input
  #   resolve('purchase_requests.default').includes(:total_amount, :status, :creator, :policy, :location, :department)
  # end

  # def request_id(purchase_request)
  #   purchase_request.order_number
  # end

  # def description(purchase_request)
  #   purchase_request.description
  # end

  # def department(purchase_request)
  #   purchase_request.department&.name
  # end

  # def location(purchase_request)
  #   purchase_request.location&.name
  # end

  # def total_items(purchase_request)
  #   purchase_request.purchase_request_items.count
  # end

  # def created_by(purchase_request)
  #   purchase_request.creator&.name
  # end

  # def status(purchase_request)
  #   purchase_request.status&.name&.titleize
  # end

  # def amount(purchase_request)
  #   purchase_request&.total_amount&.value
  # end

  # def policy(purchase_request)
  #   purchase_request.policy&.name
  # end
end