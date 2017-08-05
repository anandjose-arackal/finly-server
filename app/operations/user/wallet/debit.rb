# params = {receiving_account: :virtual_account/wallet,initiating_account: wallet/card, initiating_user_id: 1, password: 'password' }
class User::Wallet::Debit < User::Wallet::Base

  attr_accessor :payment_request

  def init
    super
  end

  def validate_sufficient_funds

  end

  def process

    # create the payment request object and pass it to the payment processor for the actual credit
    self.payment_request = PaymentRequest.(initiating_user, initiating_account, receiving_account.class.name, :debit, :advance)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(receiving_user, receiving_account, self.amount))

    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(initiating_user, {payment_request: payment_request})
    unless op.success?
      # destroy the payment order that was created for this purpose, and return errors
      op.payment_order.destroy
      add_message :error, op.messages[:error]
    end

  end

  def post_process
    add_message :success, "Withdrawal was successful"
    Event::EWallet::Debit.(self.user, payment: self.payment)
  end

  def success
    params[:payment] = self.payment
    User::Wallet::Debit::SuccessPresenter.new(user, params, messages)
  end

  class User::Wallet::Debit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end
