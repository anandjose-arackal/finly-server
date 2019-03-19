class Procurements::PurchaseRequests::Show < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :policies
  def init

    pr_id = params[:id] || params[:purchase_request_id]
    self.purchase_request = user.company.purchase_requests.find_by(id: pr_id)

  end

  def validate
    if self.purchase_request.blank?
      add_message :error, "Purchase Request not found for this user."
    end

  end

  def process

  end

  def success
    # params[:purchase_requests] = self.purchase_requests
    Procurements::PurchaseRequests::Show::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Show::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end

  end
end