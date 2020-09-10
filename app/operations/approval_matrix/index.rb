class ApprovalMatrix::Index < BaseOperation
  attr_accessor :policies, :document_type

  def init
    self.document_type = params[:document_type]
    self.policies = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.id_for(:vendor_creator)]}).policies
  end

  def validate
    add_message(:error, "Invalid Document Type") unless document_type.present?
  end

  def success
    if user.company.vendor_empanelment_workflow_enabled?
      params[:policies] = self.policies
    end
    ApprovalMatrix::Index::IndexPresenter.new(user, params, messages)
  end

  class ApprovalMatrix::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies, :approval_workflow, :reviewal_chains

    def init
      if user.company.vendor_empanelment_workflow_enabled?
        self.reviewal_chains = []
        self.policies = params[:policies]

        params[:provider_name] = "YesBankVendorProvider"
        policies.each do |policy|
          params[:policy_id] = policy.id
          chain = {
              policy_id: policy.id,
              reviewal_chain: get_reviewal_chain
          }
          self.reviewal_chains.push(chain)
        end
      else
        self.vendor_approval_workflow = false
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      if op.success?
        return op.chain
      else
        return nil
      end
    end
  end
end