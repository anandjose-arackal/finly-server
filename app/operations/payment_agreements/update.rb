class PaymentAgreements::Update < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params

  def init
    super
    self.payment_agreement_params = payment_agreement_parameters
    self.payment_agreement = user.company.payment_agreements.find_by_id(params[:id])

  end

  def process
    self.payment_agreement.assign_attributes(payment_agreement_parameters)

    if self.payment_agreement.save
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
    add_message :success, 'Successfully updated agreements'
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::Update::UpdatePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Update::UpdatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
    end
  end
end