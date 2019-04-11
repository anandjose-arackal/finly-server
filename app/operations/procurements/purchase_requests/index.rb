class Procurements::PurchaseRequests::Index < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests, :policies
  def init

  end

  def validate

  end

  def process

  end

  def success
    # params[:purchase_requests] = self.purchase_requests
    Procurements::PurchaseRequests::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests, :paginated_purchase_requests, :count

    has_scope :filter_by_status_id
    has_scope :search_by_email

    def init
      # self.purchase_requests = params[:purchase_requests]
      # To be used for dummy api
      self.purchase_requests = user.company.purchase_requests
      self.purchase_requests = apply_scopes(purchase_requests, params)
      self.paginated_purchase_requests = purchase_requests.paginate(page: params[:page], per_page: 30) rescue nil
      self.count = purchase_requests.count
    end

  end
end