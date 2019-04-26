class Procurements::PurchaseRequests::Count < Procurements::PurchaseRequests::Base

  attr_accessor :statuses

  def init
    self.statuses ||= {}
  end

  def validate
  end

  def process
    result  = ::Procurements::PurchaseRequests::Index.(user, params)
    if result.success?
      self.statuses = result.purchase_requests.joins(:status).group('purchase_request_statuses.name').count
    end
  end

  def success
    params[:statuses] = self.statuses
    Procurements::PurchaseRequests::Count::CountPresenter.new(user, params, messages)    
  end

  class Procurements::PurchaseRequests::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :statuses

    def init
      self.statuses = params[:statuses]
    end

  end

end