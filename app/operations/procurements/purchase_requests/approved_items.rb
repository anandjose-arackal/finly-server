class Procurements::PurchaseRequests::ApprovedItems < Procurements::PurchaseRequests::Base

  attr_accessor :approved_purchase_request_items, :policies
  def init

  end

  def validate

  end

  def process

  end

  def success
    # params[:purchase_requests] = self.purchase_requests
    Procurements::PurchaseRequests::ApprovedItems::ApprovedItemsPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::ApprovedItems::ApprovedItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :approved_purchase_request_items, :paginated_items, :count

    has_scope :date
    has_scope :order_number
    has_scope :vendor_id
    has_scope :item_id
    has_scope :location_id

    def init
      approved_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)]).pluck('purchase_request_items.id')
      self.approved_purchase_request_items = PurchaseRequestItem.with_ids(approved_item_ids)

      self.approved_purchase_request_items = apply_scopes(self.approved_purchase_request_items, params)
      self.paginated_items = self.approved_purchase_request_items.paginate(page: params[:page], per_page: 30) rescue nil
      self.count = self.approved_purchase_request_items.count
    end

  end

end