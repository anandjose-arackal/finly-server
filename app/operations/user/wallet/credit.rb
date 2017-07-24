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
            initiating_account_type: initiating_account.class,
            receiving_account_id: receiving_account.id,
            receiving_account_type: receiving_account.class,
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
    # payment_attributes = {}
    # payment_attributes[:initiating_user] = initiating_user
    # payment_attributes[:receiving_user] = receiving_user
    # payment_attributes[:date] = DateUtils.local_date
    # payment_attributes[:note] = params[:note]
    # payment_attributes[:payment_type_id] = PaymentType.id_for(:credit)
    # payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
    # payment_attributes[:initiating_account] = initiating_account
    # payment_attributes[:receiving_account] = receiving_account
    # payment_attributes[:payment_status_id] = PaymentStatus.id_for(:completed)
    # self.payment = Payment.new payment_attributes
    #
    # unless self.payment.valid?
    #   add_message :error, self.payment.errors.full_messages
    #   return
    # end
    #
    # case initiating_account_type
    #   when :virtual_account
    #     if receiving_account_type == :wallet
    #
    #       if receiving_user.wallet.add_funds(self.amount)
    #         # Credit company wallet balance when funds are transferred from virtual account to wallet
    #         user.company.account.funds_credited_to_wallet(self.amount)
    #         self.payment.save
    #       else
    #         add_message :error, receiving_user.wallet.errors.full_messages
    #       end
    #
    #     elsif receiving_account_type == :card
    #
    #       credit_presenter = ItzCash::Credit.(receiving_user, card_id: receiving_account_id, amount: self.amount)
    #       unless credit_presenter.success?
    #         add_message :error, credit_presenter.messages[:error]
    #         return
    #       end
    #
    #       self.payment.save
    #
    #     end
    #   when :wallet
    #
    #     if receiving_account_type == :wallet
    #       if initiating_user.wallet.subtract_funds(self.amount)
    #         receiving_user.wallet.add_funds(self.amount)
    #         self.payment.save
    #
    #         add_message :success, 'Credit successful'
    #       else
    #         add_message :error, initiating_user.wallet.errors.full_messages
    #       end
    #
    #     elsif receiving_account_type == :card
    #
    #       credit_presenter = ItzCash::Credit.(receiving_user, card_id: receiving_account_id, amount: self.amount)
    #       if credit_presenter.success?
    #         initiating_user.wallet.subtract_funds(self.amount)
    #         # Reduce company wallet balance when funds are transferred from wallet to card
    #         user.company.account.funds_debited_from_wallet(self.amount)
    #         self.payment.save
    #
    #         add_message :success, 'Credit successful'
    #       else
    #         add_message :error, credit_presenter.messages[:error]
    #       end
    #
    #     end
    #   when :card
    #     if receiving_account_type == :card
    #       # first reduce the amount from the card holder's balance
    #       # duplicating the params hash first
    #       debit_presenter = ItzCash::Debit.(initiating_user, card_id: initiating_account_id, amount: self.amount)
    #       # if the debit is successful, i.e. if the money has been reduced from the card holder's account
    #       if debit_presenter.success?
    #         # now add the money to the receiving user's card
    #         credit_presenter = ItzCash::Credit.(receiving_user, card_id: receiving_account_id, amount: self.amount)
    #         unless credit_presenter.success?
    #           # throw error message saying debit is successful but credit was unsuccessful
    #           add_message :error, 'Amount could not be credited, the funds will be transferred to your company balance'
    #           return
    #         end
    #
    #         self.payment.save
    #         add_message :success, 'Credit successful'
    #
    #       else
    #         add_message :error, 'Amount could not be debited, please try later'
    #         return
    #       end
    #     elsif receiving_account_type == :wallet
    #       debit_presenter = ItzCash::Debit.(initiating_user, card_id: initiating_account_id, amount: self.amount)
    #       if debit_presenter.success?
    #         # i.e. the money was successfully deducted
    #         # deducting money from the company balance
    #         user.company.account.funds_credited_to_wallet(self.amount)
    #         # add funds to receiving user waller
    #         receiving_user.wallet.add_funds(self.amount)
    #         self.payment.save
    #
    #         add_message :success, 'Credit successful'
    #       else
    #         add_message :error, 'Could not debit funds, please try again later'
    #       end
    #     end
    # end
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
