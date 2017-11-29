class Invoicing::PaymentReceivable::Base < BaseOperation

  class Invoicing::PaymentReceivable::Base::ReceivablePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_receivable, :virtual_bank_account

    def init
      self.payment_receivable = params[:payment_receivable]
      self.virtual_bank_account = params[:virtual_bank_account]
    end
  end
end