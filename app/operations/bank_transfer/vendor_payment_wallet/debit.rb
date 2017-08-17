class BankTransfer::VendorPaymentWallet::Debit < BankTransfer::VendorPaymentWallet::Base

  attr_accessor :payment_request

  def process
    self.payment_request = PaymentRequest.(user, initiating_account. receiving_account.class.name, :debit, :balance_clearance)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(receiving_user, receiving_account, self.amount))

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.payment = op.payment_order.payments.first
  end

  def post_process
    add_message :success, "Payment was successful"
    # trigger notification if necessary
  end

  def success
    params[:payment] = self.payment
    BankTransfer::VendorPaymentWallet::Credit::VendorWalletPresenter.new(user, params, messages)
  end

  class BankTransfer::VendorPaymentWallet::Credit::VendorWalletPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end
end