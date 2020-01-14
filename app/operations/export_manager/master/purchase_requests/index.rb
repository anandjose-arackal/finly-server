class ExportManager::Master::PurchaseRequests::Index < ExportManager::Builders::Spreadsheet
  attr_accessor :input_data

  label 'Export'
  description 'Purchase Requests Export'
  configurable true
  system :vp
  screen 'purchase_requests.index'
  handle :purchase_request
  validate :input

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
    return self.input_data unless self.input_data.nil?

    purchase_request_presenter = ::Procurements::PurchaseRequests::Index.(user, params)

    unless purchase_request_presenter.success?
      add_message :error, purchase_request_presenter.messages[:error]
      return
    end

    purchase_request_presenter.purchase_requests.includes(:total_amount, :status, :creator, :policy, :location, :department)
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