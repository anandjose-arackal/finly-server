class PaymentAgreements::Index < PaymentAgreements::Base

  class PaymentAgreements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreements

    def init
      self.payment_agreements = user.company.payment_agreements
    end
  end

end 