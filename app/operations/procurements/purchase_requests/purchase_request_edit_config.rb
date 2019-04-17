# this operation returns the details of the particular policies and locations and departments that the user belongs
# to so that the respective fields can be populated inside the dropdowns inside the PR show
class Procurements::PurchaseRequests::PurchaseRequestEditConfig < Procurements::PurchaseRequests::Base

  attr_accessor :purchase_request

  class Procurements::PurchaseRequests::PurchaseRequestEditConfig::EditConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :departments, :policies, :reviewal_chains, :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
      self.locations = user.company.locations
      # Admin should also be initiator for the policy
      self.locations = user.initiator_associated_locations(UserRole.id_for(:purchase_request_initiator)).leaves
      # self.departments = user.company.departments
      self.departments = user.initiator_associated_departments(UserRole.id_for(:purchase_request_initiator)).leaves
      params[:filter_role_id] = [UserRole.id_for(:purchase_request_initiator)]
      self.policies = Policy::VendorPayments::Index.(user, params).policies
      self.reviewal_chains = []
      params[:reviewal_document] = purchase_request

      self.policies.each do |policy|
        params = {
            policy_id: policy.id,
            provider_name: "PurchaseRequestProvider",
            reviewal_document: self.purchase_request
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

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      op.chain
    end
  end

  def init
    id = params[:id] || params[:purchase_request_id]
    self.purchase_request = Procurements::PurchaseRequests::Show.(user, params).purchase_request rescue nil
    # self.purchase_request = nil
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