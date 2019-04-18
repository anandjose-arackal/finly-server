class Procurements::PurchaseRequests::SaveAndSubmit < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :purchase_request_params

  class Procurements::PurchaseRequests::SaveAndSubmit::SaveAndSubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end

  # def init
  #   id = params[:id] || params[:purchase_request_id]
  #   self.purchase_request = Procurements::PurchaseRequests::Show.(user, params).purchase_request.with_id(id).first rescue nil
  # end

  def process
    update_result = Procurements::PurchaseRequests::Update.(user, params)
    if result.success?
      submit_result = Procurements::PurchaseRequests::Submit.(user, params)
    end
  end

  def post_process
    params[:purchase_request] = submit_result.purchase_request
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::SaveAndSubmit::SaveAndSubmitPresenter.new(user, params, messages)
  end
end