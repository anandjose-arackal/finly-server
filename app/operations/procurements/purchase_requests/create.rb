class Procurements::PurchaseRequests::Create < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests, :policies
  def init

  end

  def validate

  end

  def process

  end

  def success
    # params[:purchase_requests] = self.purchase_requests
    Procurements::PurchaseRequests::Create::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Create::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests

    def init
      self.purchase_requests = params[:purchase_requests]
    end

  end
end