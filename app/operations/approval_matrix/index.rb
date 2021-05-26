class ApprovalMatrix::Index < BaseOperation
  attr_accessor :policies, :document_type, :provider_name

  def init
    self.document_type = params[:document_type]
    role = nil
    # self.provider_name = params[:provider_name]

    case document_type
    when 'vendors'
      role = :vendor_creator
      self.provider_name = 'YesBankVendorProvider'
    when 'invoices'
      document = current_user.company.inward_invoices.find_by(params[:document_id])

      self.provider_name = document.get_invoice_provider_name

      if self.provider_name == 'PoInvoiceProvider'
        role = :po_invoice_initiator
      elsif self.provider_name == 'NonPoInvoiceProvider'
        role = :non_po_invoice_initiator
      elsif self.provider_name == 'AgreementInvoiceProvider'
        role = :agreement_invoice_initiator
      else
        # do nothing
      end
    end

    if role.present?
      self.policies = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.id_for(:role)]}).policies
    else
      add_message :error, "Not able to retrieve approval matrix"
    end
  end

  def validate
    add_message(:error, "Invalid Document Type") unless document_type.present?
  end

  def success
    if user.company.vendor_empanelment_workflow_enabled?
      params[:policies] = self.policies
      params[:provider_name] = self.provider_name
    end
    ApprovalMatrix::Index::IndexPresenter.new(user, params, messages)
  end

  class ApprovalMatrix::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies, :approval_workflow, :reviewal_chains

    def init
      self.reviewal_chains = []
      self.policies = params[:policies]
      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }
        self.reviewal_chains.push(chain)
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