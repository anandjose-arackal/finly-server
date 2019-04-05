class Procurements::PurchaseRequests::Update < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :policies, :purchase_request_params

  # def init
  #   self.purchase_request_params = purchase_request_parameters
  #   pr_id = params[:id] || params[:purchase_request_id]
  #   self.purchase_request = user.company.purchase_requests.find_by(id: pr_id)

  # end

  # def validate
  #   if self.purchase_request.blank?
  #     add_message :error, "Purchase Request not found for this user."
  #   end
  # end

  def process
    self.purchase_request.assign_attributes(self.purchase_request_params)

    unless self.purchase_request.save
      # self.purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:draft))
      add_message :error, purchase_request.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Successfully updated purchase request'
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Create::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Update::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end
end