# this operation returns the details of the particular policies and locations and departments that the user belongs
# to so that the respective fields can be populated inside the dropdowns inside the PR show
class Procurements::PurchaseRequests::PurchaseRequestEditConfig < Procurements::PurchaseRequests::Base

  attr_accessor :purchase_request

  class Procurements::PurchaseRequests::PurchaseRequestEditConfig::EditConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :departments, :policies, :reviewal_chains, :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
      self.locations = user.branch_locations
      self.departments = user.departments
      self.policies = user.policies
      self.reviewal_chains = []
      self.policies.each do |policy|
        params = {
            policy_id: policy.id,
            # provider_name: "PurchaseRequestProvider",
            provider_name: "BankPaymentRequestProvider",
            document: self.purchase_request
        }
        op = ::ReviewalManager::ReviewalChain.(user, params)
        if op.success?
          policy_chain = op.chain
        else
          policy_chain = nil
        end
        chain = {
            policy_id: policy.id,
            reviewal_chain: policy_chain
        }
        self.reviewal_chains.push(chain)
      end
    end
  end

  def init
    id = params[:id] || params[:purchase_request_id]
    # self.purchase_request = Procurements::PurchaseRequests::Index.(user, params).purchase_requests.find_by(id: id) rescue nil
    self.purchase_request = nil
  end

  def validate
    # if self.purchase_request.blank?
    #   add_message :error, "Purchase Request not found"
    #   return
    # end
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::PurchaseRequestEditConfig::EditConfigPresenter.new(user, params, messages)
  end

end