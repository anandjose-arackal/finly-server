class PaymentAgreements::PolicyConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement

  class PaymentAgreements::PolicyConfig::PolicyConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :departments, :policies, :reviewal_chains, :payment_agreement, :cost_centers, :department_mappings, :location_mappings, :policy

    def init
      self.policy = params[:policy]
      params[:filter_role_id] = [UserRole.id_for(:payment_agreement_initiator)]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.departments = Company::Departments::Index.(initiating_user, params).policy_department_filter_mapping&.leaves
      self.locations = Company::Locations::Index.(initiating_user, params).policy_location_filter_mapping&.leaves
      self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
      self.cost_centers = user.company.cost_centers
      self.reviewal_chains = []
      self.department_mappings = []
      params[:reviewal_document] = payment_agreement

      self.policies.each do |policy|
        params = {
            policy_id: policy.id,
            provider_name: "PaymentAgreementProvider",
            reviewal_document: self.payment_agreement
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
        self.department_mappings.push(get_department_mapping(policy))
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      op.chain
    end

    def get_department_mapping(policy)
      {
        policy_id: policy.id,
        departments: policy.departments.as_json
      }
    end
  end

  def init
    id = params[:id] || params[:policy_id]
    self.policy = Policy::VendorPayments::Index.(user, params).policies.find_by_id id
  end

  def validate
    if policy.blank?
      add_message :error, 'Policy not found'
    end
  end


  def success
    params[:policy] = self.policy
    PaymentAgreements::PolicyConfig::PolicyConfigPresenter.new(user, params, messages)
  end
end