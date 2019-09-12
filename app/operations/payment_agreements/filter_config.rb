class PaymentAgreements::FilterConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement

  class PaymentAgreements::FilterConfig::FilterConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policies, :payment_agreement, :agreement_types

    def init
      self.payment_agreement = params[:payment_agreement]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
      self.agreement_types = ::PaymentAgreement::AGREEMENT_TYPES
    end
  end

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement rescue nil
  end


  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::FilterConfig::FilterConfigPresenter.new(user, params, messages)
  end

end