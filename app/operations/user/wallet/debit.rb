# params = {receiving_account: :virtual_account/wallet,initiating_account: wallet/card, initiating_user_id: 1, password: 'password' }
class User::Wallet::Debit < User::Wallet::Base
  
  def validate_sufficient_funds
    if receiving_account_type == :wallet and receiving_account.balance_value < self.amount
      add_message :error, 'Insufficient funds to initiate the transfer'
      return
    end
    if receiving_account_type == :virtual_account
      balance_presenter = Company::VirtualAccount::Balance.(user, params)
      if balance_presenter.success?
        balance_amount = balance_presenter.balance
        if balance_amount < self.amount
          add_message :error, 'Insufficient balance in your Finly Account to initiate this transfer'
        end
      else
        add_message :error, balance_presenter.messages[:error]
      end
    end
    if receiving_account_type == :card and receiving_account.card_balance.present? and receiving_account.card_balance.value < self.amount
      add_message :error, 'Insufficient funds in the card to initiate the transfer'
    end
    if initiating_account_type == :card and self.amount > 50000
      add_message :error, 'Cannot transfer the given amount. Please reduce the amount and try again'
    end
  end

  def process

    payment_attributes = {}
    payment_attributes[:initiating_user] = initiating_user
    payment_attributes[:receiving_user] = target_user
    payment_attributes[:date] = DateUtils.local_date
    payment_attributes[:note] = params[:note]
    payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
    payment_attributes[:payment_type_id] = PaymentType.id_for(:credit)
    payment_attributes[:initiating_account] = initiating_account
    payment_attributes[:receiving_account] = receiving_account
    self.payment = Payment.new payment_attributes

    unless self.payment.valid?
      add_message :error, self.payment.errors.full_messages
      return
    end

    case receiving_account
      when :wallet

        if initiating_account == :wallet

          if target_user.wallet.subtract_funds(self.amount)
            initiating_user.wallet.add_funds(self.amount)

            add_message :success, 'Debit successful'
            self.payment.save
          else
            add_message :error, target_user.wallet.errors.full_messages
          end

        elsif initiating_account == :virtual_account

          if target_user.wallet.subtract_funds(self.amount)
            user.company.account.funds_debited_from_wallet(self.amount)

            self.payment.save
          else
            add_message :error, initiating_user.wallet.errors.full_messages
          end

        elsif initiating_account == :card
          target_user.wallet.subtract_funds(self.amount)
          credit_presenter = ItzCash::Credit.(initiating_user, card_id: receiving_account_id, amount: self.amount)
          if credit_presenter.success?

            add_message :success, "Debit successful"
            self.payment.save
          else
            # restore funds to target_user's wallet
            target_user.wallet.add_funds(self.amount)
            add_message :error, credit_presenter.messages[:error]
          end

        end

      when :card

        if initiating_account == :virtual_account
          debit_presenter = ItzCash::Debit.(target_user, card_id: target_account_id, amount: self.amount)
          unless debit_presenter.success?
            add_message :error, 'Money debit failed, please try again later'
            return
          end
          self.payment.save
          add_message :success, 'Debit successful'

        elsif initiating_account == :wallet

          debit_presenter = ItzCash::Debit.(target_user, card_id: target_account_id, amount: self.amount)
          unless debit_presenter.success?
            add_message :error, 'Money debit failed, please try again later'
            return
          end
          # the money has moved from the card to the virtual account already, now we need to move it from virtual account to wallet
          # add funds to the initiating user's wallet
          initiating_user.wallet.add_funds(self.amount)
          # subtract this amount from the company funds
          initiating_user.company.account.funds_credited_to_wallet(self.amount)
          self.payment.save
          add_message :success, 'Debit successful'

        elsif initiating_account == :card
          # first reduce the amount from the card holder's balance
          # duplicating the params hash first
          debit_presenter = ItzCash::Debit.(target_user, card_id: target_account_id, amount: self.amount)
          # if the debit is successful, i.e. if the money has been reduced from the card holder's account
          if debit_presenter.success?
            # now add the money to the target user's card
            credit_presenter = ItzCash::Credit.(initiating_user, card_id: receiving_account_id, amount: self.amount)
            unless credit_presenter.success?
              # throw error message saying debit is successful but credit was unsuccessful
              add_message :error, 'Amount could not be credited, the funds will be transferred to your company balance'
              return
            end

            self.payment.save
            add_message :success, 'Debit successful'

          else
            add_message :error, 'Amount could not be debited, please try later'
            return
          end
        end

      when :virtual_account
        # don't think this is a legit possibility.
    end
  end

  def post_process
    Event::EWallet::Debit.(self.user, payment: self.payment)
  end

end
