class PaymentAgreements::Create < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params

  def init
    self.payment_agreement_params = payment_agreement_parameters
  end

  def validate
    unless user.is_payment_agreement_initiator?
      add_message :error, 'You do not have permission for this action'
      return
    end
  end

  def process
    self.payment_agreement = PaymentAgreement.new(payment_agreement_params)
    self.payment_agreement.creator_id = user.id
    self.payment_agreement.status_id = PaymentAgreementStatus.id_for(:draft)

    if self.payment_agreement.save
      # Create document level reviewer mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.payment_agreement
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
      end
      return
    else
      add_message :error, payment_agreement.errors.full_messages
      return
    end

  end

  def post_process
    add_message :success, 'Successfully created agreement'
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::Create::CreatePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
    end

  end

end