class Invoicing::PaymentReceivable::Base < BaseOperation

  class Invoicing::PaymentReceivable::Base::ReceivablePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_receivable

    def init
      self.payment_receivable = params[:payment_receivable]
    end
  end
end