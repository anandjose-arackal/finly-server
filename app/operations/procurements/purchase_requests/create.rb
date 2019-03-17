class Procurements::PurchaseRequests::Create < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :policies, :purchase_request_params
  def init
    self.purchase_request_params = purchase_request_parameters

  end

  def validate

  end

  def process
    self.purchase_request = PurchaseRequest.new(self.purchase_request_params)
    self.purchase_request.user = user
    self.purchase_request.company = user.company

    if self.purchase_request.save
      self.purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))
    else
      add_message :error, purchase_request.errors.full_messages
    end

  end

  def post_process
    add_message :success, 'Successfully created purchase request'
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Create::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Create::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end

  end
end