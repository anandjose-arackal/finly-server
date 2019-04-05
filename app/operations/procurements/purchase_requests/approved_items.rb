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

    def init
      self.approved_purchase_request_items = user.company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)])
      self.paginated_items = approved_purchase_request_items.paginate(page: params[:page], per_page: 30) rescue nil
      self.count = approved_purchase_request_items.count
    end

  end

end