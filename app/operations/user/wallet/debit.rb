# params = {from_account: :virtual_account/wallet,to_account: wallet/card, to_user_id: 1, password: 'password' }
class User::Wallet::Debit < User::Wallet::Base
  attr_accessor :target_user, :initiating_user, :target_account, :initiating_account, :amount, :payment

  def authorized_user_types
    if params.present? and params[:from_account].present? and params[:to_account].present?
      if params[:from_account].to_sym == :virtual_account or params[:to_account].to_sym == :virtual_account
        return :company_admin
      elsif params[:from_account].to_sym == :wallet and params[:to_account].to_sym == :wallet
        return [:admin, :manager, :finance_manager]
      end
    end
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    if params.blank? or params[:from_account].blank? or params[:to_account].blank? or
        (params[:from_user].blank? and params[:from_user_id].blank?)
      add_message :error, 'Invalid request'
    end
  end

  def init
    super
    self.amount= params[:amount].to_d rescue nil
    self.target_account = params[:from_account].to_sym rescue nil
    self.initiating_account = params[:to_account].to_sym rescue nil
    self.initiating_user = user
    self.target_user = params[:from_user]
    if target_user.blank? and params[:from_user_id].present?
      users = User::Team::Index.(user, params)
      self.target_user = (users.with_id(params[:from_user_id]).first rescue nil) if users.present?
    end
  end

  def validate
    super
    if self.amount.blank?
      add_message :error, 'Amount cannot be blank'
    end
    if target_user.blank? or initiating_user.blank?
      add_message :error, 'User not found'
    end
    if target_account.blank? or initiating_account.blank?
      add_message :error, 'Account cannot be blank'
    end
    return if has_errors?
    if initiating_account == :card and initiating_user.cards.blank?
      add_message :error, 'User is not associated with a card to initiate this transfer'
      return
    end
    if target_account == :wallet and target_user.wallet.balance_value < self.amount
      add_message :error, 'Insufficient funds to initiate the transfer'
    end
    unless (target_account == :wallet) and (initiating_account == :virtual_account or initiating_account == :wallet)
      add_message :error, 'Invalid Request'
    end
  end

  def process

    payment_attributes = {}
    payment_attributes[:initiating_user] = initiating_user
    payment_attributes[:receiving_user] = target_user
    payment_attributes[:date] = DateUtils.local_date
    payment_attributes[:note] = params[:note]
    payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

    case target_account
      when :wallet

        if initiating_account == :wallet

          if target_user.wallet.subtract_funds(self.amount)
            initiating_user.wallet.add_funds(self.amount)

            payment_attributes[:payment_type_id] = PaymentType.id_for(:debit_from_wallet_to_wallet)
            self.payment = Payment.create payment_attributes
          else
            add_message :error, target_user.wallet.errors.full_messages
          end

        elsif initiating_account == :virtual_account

          if target_user.wallet.subtract_funds(self.amount)
            user.company.account.funds_debited_from_wallet(self.amount)

            payment_attributes[:payment_type_id] = PaymentType.id_for(:debit_from_wallet_to_virtual_account)
            self.payment = Payment.create payment_attributes
          else
            add_message :error, initiating_user.wallet.errors.full_messages
          end

        end

      when :card

        if initiating_account == :virtual_account
          debit_presenter = ItzCash::Debit.(target_user, params)
          unless debit_presenter.success?
            add_message :error, "Money debit failed, please try again later"
          end
          payment_attributes[:payment_type_id] = PaymentType.id_for(:debit_from_card_to_virtual_account)

        elsif initiating_account == :wallet
          debit_presenter = ItzCash::Debit.(target_user, params)
          unless debit_presenter.success?
            add_message :error, "Money debit failed, please try again later"
          end
          # the money has moved from the card to the virtual account already, now we need to move it from virtual account to wallet
          # add funds to the initiating user's wallet
          initiating_user.wallet.add_funds(self.amount)
          # subtract this amount from the company funds
          initiating_user.company.account.funds_credited_to_wallet(self.amount)
          payment_attributes[:payment_type_id] = PaymentType.id_for(:debit_from_card_to_wallet)

        elsif initiating_account == :card
          # first reduce the amount from the card holder's balance
          debit_presenter = ItzCash::Debit.(target_user, params)
          # if the debit is successful, i.e. if the money has been reduced from the card holder's account
          if debit_presenter.success?
            # now add the money to the target user's card
            credit_presenter = ItzCash::Credit.(initiating_user, params)
            unless credit_presenter.success?
              # throw error message saying debit is successful but credit was unsuccessful
              add_message :error, "Amount could not be credited, the funds will be transferred to your company balance"
              return
            end
          else
            add_message :error, "Amount could not be debited, please try later"
            return
          end
          payment_attributes[:payment_type_id] = PaymentType.id_for(:debit_from_card_to_card)
        end

      when :virtual_account
        # don't think this is a legit possibility.
    end
  end

  def post_process
    Event::EWallet::Debit.(self.user, payment: self.payment)
  end

end
