class PaymentAgreements::Attachments < PaymentAgreements::Base
  attr_accessor :attachments, :payment_agreement

  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
    end
  end

  def process
    self.attachments = payment_agreement.attachments
  end

  def success
    params[:attachments] = attachments
    PaymentAgreements::Attachments::AttachmentsPresenter.new(user, params, messages)
  end

  class PaymentAgreements::Attachments::AttachmentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachments

    def init
      self.attachments = params[:attachments]
    end
  end 




end