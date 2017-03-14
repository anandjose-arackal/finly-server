# params = {from_account: :virtual_account/wallet,to_account: wallet/card, to_user_id: 1, password: 'password' }
class User::Wallet::Credit < User::Wallet::Base
  attr_accessor :initiating_user, :target_user, :from_account, :from_account_id, :target_account, :target_account_id, :amount, :payment

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
      (params[:to_user].blank? and params[:to_user_id].blank?)
      add_message :error, 'Invalid request'
      return
    end
    if params[:from_account] == :card and params[:from_account_id].blank?
      add_message :error, 'Card not found'
      return
    end
    if params[:to_account] == :card and params[:to_account_id].blank?
      add_message :error, 'Card not found'
      return
    end
  end

  def init
    super
    self.amount= params[:amount].to_d rescue nil
    self.from_account = params[:from_account].to_sym rescue nil
    self.target_account = params[:to_account].to_sym rescue nil
    self.initiating_user = user
    self.target_user = params[:to_user]
    if target_user.blank? and params[:to_user_id].present?
      if params[:to_user_id].to_i == user.id
        self.target_user = user
      else
        users = User::Team::Index.(user, params)
        self.target_user = (users.with_id(params[:to_user_id]).first rescue nil) if users.present?
      end
    end
  end

  def validate
    super
    if self.amount.blank?
      add_message :error, 'Amount cannot be blank'
    end
    if initiating_user.blank? or target_user.blank?
      add_message :error, 'User not found'
    end
    if from_account.blank? or target_account.blank?
      add_message :error, 'Account cannot be blank'
    end
    return if has_errors?
    if target_account == :card and target_user.cards.blank?
      add_message :error, 'User is not associated with a card to initiate this transfer'
      return
    end
    if from_account == :wallet and initiating_user.wallet.balance_value < self.amount
      add_message :error, 'Insufficient funds to initiate the transfer'
      return
    end
    if from_account == :virtual_account
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
    if target_account == :card and self.amount > 50000
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

    case from_account
      when :virtual_account
        if target_account == :wallet

          if target_user.wallet.add_funds(self.amount)
            # Credit company wallet balance when funds are transferred from virtual account to wallet
            user.company.account.funds_credited_to_wallet(self.amount)

            payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_virtual_account_to_wallet)
            self.payment = Payment.create payment_attributes
          else
            add_message :error, target_user.wallet.errors.full_messages
          end

        elsif target_account == :card

          credit_presenter = ItzCash::Credit.(target_user, card_id: target_account_id, amount: self.amount)
          unless credit_presenter.success?
            add_message :error, credit_presenter.messages[:error]
            return
          end

          payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_virtual_account_to_card)
          self.payment = Payment.create payment_attributes

        end
      when :wallet

        if target_account == :wallet
          if initiating_user.wallet.subtract_funds(self.amount)
            target_user.wallet.add_funds(self.amount)
            payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_wallet_to_wallet)
            self.payment = Payment.create payment_attributes

            add_message :success, 'Credit successful'
          else
            add_message :error, initiating_user.wallet.errors.full_messages
          end

        elsif target_account == :card

          credit_presenter = ItzCash::Credit.(target_user, card_id: target_account_id, amount: self.amount)
          if credit_presenter.success?
            initiating_user.wallet.subtract_funds(self.amount)
            # Reduce company wallet balance when funds are transferred from wallet to card
            user.company.account.funds_debited_from_wallet(self.amount)

            payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_wallet_to_card)
            self.payment = Payment.create payment_attributes

            add_message :success, 'Credit successful'
          else
            add_message :error, credit_presenter.messages[:error]
          end

        end
      when :card
        if target_account == :card
          # first reduce the amount from the card holder's balance
          # duplicating the params hash first
          debit_params = params.deep_dup
          debit_presenter = ItzCash::Debit.(initiating_user, card_id: from_account_id, amount: self.amount)
          # if the debit is successful, i.e. if the money has been reduced from the card holder's account
          if debit_presenter.success?
            # now add the money to the target user's card
            credit_presenter = ItzCash::Credit.(target_user, card_id: target_account_id, amount: self.amount)
            unless credit_presenter.success?
              # throw error message saying debit is successful but credit was unsuccessful
              add_message :error, "Amount could not be credited, the funds will be transferred to your company balance"
              return
            end

            payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_card_to_card)

            self.payment = Payment.create payment_attributes
            add_message :success, 'Credit successful'

          else
            add_message :error, "Amount could not be debited, please try later"
            return
          end
        elsif target_account == :wallet
          debit_presenter = ItzCash::Debit.(initiating_user, card_id: from_account_id, amount: self.amount)
          if debit_presenter.success?
            # i.e. the money was successfully deducted
            # deducting money from the company balance
            user.company.account.funds_credited_to_wallet(self.amount)
            # add funds to target user waller
            target_user.wallet.add_funds(self.amount)
            payment_attributes[:payment_type_id] = PaymentType.id_for(:credit_from_card_to_wallet)

            self.payment = Payment.create payment_attributes
            add_message :success, 'Credit successful'
          else
            add_message :error, "Could not debit funds, please try again later"
          end
        end
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
