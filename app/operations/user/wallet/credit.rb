# params = {initiating_account_id: :virtual_account/wallet,receiving_account_type: wallet/card, receiving_user_id: 1, password: 'password' }
# this operation will now purely do the EM specific validations and create the payment request object for
# crediting / debiting from the respective accounts

class User::Wallet::Credit < User::Wallet::Base

  attr_accessor :payment_request

  def init
    super

  end

  def validate_sufficient_funds

  end

  def process
    # create the payment request object and pass it to the payment processor for the actual credit
    self.payment_request = PaymentRequest.(initiating_user, initiating_account, receiving_account.class.name, :credit, :advance)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(receiving_user, receiving_account, self.amount))

    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(initiating_user, {payment_request: payment_request})
    unless op.success?
      # destroy the payment order that was created for this purpose, and return errors
      op.payment_order.destroy
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:payment] = self.payment
    User::Wallet::Credit::SuccessPresenter.new(user, params, messages)
  end

  def post_process
    add_message :success, "Payment was successful"
    Event::EWallet::Credit.(self.user, payment: self.payment)
  end

  class User::Wallet::Credit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end
