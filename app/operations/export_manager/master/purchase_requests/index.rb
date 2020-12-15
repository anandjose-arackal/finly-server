class ExportManager::Master::PurchaseRequests::Index < ExportManager::Builders::Spreadsheet
  attr_accessor :input_data

  label 'Spreadsheet'
  description 'Purchase Requests Export'
  configurable true
  system :vp
  screen 'purchase_requests.index'
  handle :purchase_request

  has_template true

  attribute :request_id
  attribute :description
  attribute :department
  attribute :location
  attribute :policy
  attribute :total_items
  attribute :created_by
  attribute :status
  attribute :amount

  def input
    resolve('purchase_requests.default').includes(:total_amount, :status, :creator, :policy, :location, :department)
  end

  def request_id(purchase_request)
    purchase_request.order_number
  end

  def description(purchase_request)
    purchase_request.description
  end

  def department(purchase_request)
    purchase_request.department&.name
  end

  def location(purchase_request)
    purchase_request.location&.name
  end

  def total_items(purchase_request)
    purchase_request.purchase_request_items.count
  end

  def created_by(purchase_request)
    purchase_request.creator&.name
  end

  def status(purchase_request)
    purchase_request.status&.name&.titleize
  end

  def amount(purchase_request)
    purchase_request&.total_amount&.value
  end

  def policy(purchase_request)
    purchase_request.policy&.name
  end
end
