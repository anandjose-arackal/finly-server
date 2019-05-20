class PaymentAgreements::PolicyConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement, :policy

  class PaymentAgreements::PolicyConfig::PolicyConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations, :departments, :policies, :reviewal_chains, :payment_agreement, :cost_centers, :department_mappings, :location_mappings, :policy, :policy_reviewal_chain

    def init
      self.policy = params[:policy]
      self.payment_agreement = params[:payment_agreement]
      params[:filter_role_id] = [UserRole.id_for(:payment_agreement_initiator)]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.departments = self.policy.departments&.leaves
      self.locations = self.policy.locations&.leaves
      self.policy_reviewal_chain = policy_reviewal_chain
      self.payment_terms = user.company.payment_terms
    end

    def policy_reviewal_chain
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
      return [chain]
    end

    def get_department_mapping(policy)
      {
        policy_id: policy.id,
        departments: policy.departments.as_json
      }
    end
  end

  def init
    policy_id = params[:policy_id]
    self.policy = Policy::VendorPayments::Index.(user, params).policies.find_by_id policy_id
    # Use params[:payment_agreement_id]
    if params[:payment_agreement_id].present?
      self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
    end
  end

  def validate
    if policy.blank?
      add_message :error, 'Policy not found'
    end
  end


  def success
    params[:policy] = self.policy
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::PolicyConfig::PolicyConfigPresenter.new(user, params, messages)
  end
end