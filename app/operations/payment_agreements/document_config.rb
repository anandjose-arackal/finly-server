class PaymentAgreements::DocumentConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement

  class PaymentAgreements::DocumentConfig::DocumentConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policies, :payment_agreement, :payment_agreement_types

    def init
      self.payment_agreement = params[:payment_agreement]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
      self.payment_agreement_types = ::PaymentAgreement::AGREEMENT_TYPES
    end
  end

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement rescue nil
  end


  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::DocumentConfig::DocumentConfigPresenter.new(user, params, messages)
  end

end