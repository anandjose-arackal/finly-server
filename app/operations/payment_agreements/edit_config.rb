class PaymentAgreements::EditConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement

  class PaymentAgreements::EditConfig::EditConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policies, :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
    end
  end

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement rescue nil
  end


  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::EditConfig::EditConfigPresenter.new(user, params, messages)
  end

end