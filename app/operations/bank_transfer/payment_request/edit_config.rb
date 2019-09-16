class BankTransfer::PaymentRequest::EditConfig < BankTransfer::PaymentRequest::Base

  attr_accessor :policies, :reviewal_chains, :bank_payment_request

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id) rescue nil
    # self.payment_order = bank_payment_request&.payment_order
  end

  def validate
    unless bank_payment_request.present?
      add_message :error, 'Payment Ticket Not Found'
    end
  end


  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::EditConfig::EditConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::EditConfig::EditConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies, :reviewal_chains, :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
      # policy_ids = self.bank_payment_request.owner.policy_user_mappings.exclude_deleted.pluck(:policy_id)
      self.policies = Policy::VendorPayments::Index.(self.bank_payment_request.owner, params).policies
      # self.policies = user.company.policies.with_id(policy_ids).with_application(:vp)

      self.reviewal_chains = []
      params[:reviewal_document] = bank_payment_request

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
      op = ::ReviewalManager::ReviewalChain.(bank_payment_request.owner, params)
      op.chain
    end
  end

end
