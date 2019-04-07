class Procurements::PurchaseRequests::Show < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :policies, :reviewal_chains
  
  def init
    pr_id = params[:id] || params[:purchase_request_id]
    self.purchase_request = user.company.purchase_requests.find_by(id: pr_id)

  end

  def validate
    if self.purchase_request.blank? || purchase_request.company_id != user.company_id
      add_message :error, "Purchase Request not found for this user."
    end
    # Add role based validations
  end

  def process

  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Show::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Show::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request, :line_items_count, :line_items, :policies, :reviewal_chains

    def init
      self.purchase_request = params[:purchase_request]
      self.line_items_count = purchase_request&.purchase_request_items&.count
      self.line_items  = purchase_request&.purchase_request_items

      # self.policies = Policy::VendorPayments::Index.(user, params).policies
      # self.reviewal_chains = []
      # params[:reviewal_document] = purchase_request

      # self.policies.each do |policy|
      #   params = {
      #       policy_id: policy.id,

      #       provider_name: "PurchaseRequestProvider",
      #       reviewal_document: self.purchase_request
      #   }
      #   op = ::ReviewalManager::ReviewalChain.(user, params)
      #   if op.success?
      #     policy_chain = op.chain
      #   else
      #     policy_chain = nil
      #   end
      #   chain = {
      #       policy_id: policy.id,
      #       reviewal_chain: policy_chain
      #   }
      #   self.reviewal_chains.push(chain)
      # end
    end

  end
end