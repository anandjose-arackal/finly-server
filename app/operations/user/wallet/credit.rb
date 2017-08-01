# params = {initiating_account_id: :virtual_account/wallet,receiving_account_type: wallet/card, receiving_user_id: 1, password: 'password' }
# this operation will now purely do the EM specific validations and create the payment request object for
# crediting / debiting from the respective accounts

class User::Wallet::Credit < User::Wallet::Base

  attr_accessor :payment_request

  def init
    super
    self.payment_request = PaymentRequest.new
  end

  def validate_sufficient_funds
    # todo - move all balance and eligibility checks to payment processor

    # if initiating_account_type == :wallet and initiating_account.balance_value < self.amount
    #   add_message :error, 'Insufficient funds to initiate the transfer'
    #   return
    # end
    # if initiating_account_type == :virtual_account
    #   balance_presenter = Company::VirtualAccount::Balance.(user, params)
    #   if balance_presenter.success?
    #     balance_amount = balance_presenter.balance
    #     if balance_amount < self.amount
    #       add_message :error, 'Insufficient balance in your Finly Account to initiate this transfer'
    #     end
    #   else
    #     add_message :error, balance_presenter.messages[:error]
    #   end
    # end
    # if initiating_account_type == :card and initiating_account.card_balance.present? and initiating_account.card_balance.value < self.amount
    #   add_message :error, 'Insufficient funds in the card to initiate the transfer'
    # end
    # if receiving_account_type == :card and self.amount > 50000
    #   add_message :error, 'Cannot transfer the given amount. Please reduce the amount and try again'
    # end
  end

  def process
    # create the payment request object and pass it to the payment processor for the actual credit
    payment_request.initiating_user_id = initiating_user.id
    payment_request.company_id = initiating_user.company_id
    payment_request.payment_order_type_id = PaymentOrderType.id_for(:expense_card)
    payment_request.scheduled_at = Date.today # basically a proxy for executing the request right now
    payment_request.synchronous = true # because this needs to be executed right away
    payment_request.payment_items = [
        {
            initiating_user_id: initiating_user.id,
            receiving_user_id: receiving_user.id,
            initiating_account_id: initiating_account.id,
            initiating_account_type: initiating_account.class.to_s,
            receiving_account_id: receiving_account.id,
            receiving_account_type: receiving_account.class.to_s,
            payment_type_id: PaymentType.id_for(:credit),
            date: Date.today,
            amount_attributes: {
                value: self.amount,
                currency_id: Currency.id_for(:INR)
            }
        }
    ]

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
    Event::EWallet::Credit.(self.user, payment: self.payment)
  end

  class User::Wallet::Credit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end
