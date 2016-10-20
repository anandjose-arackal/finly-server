# params = {from_account: :virtual_account/wallet,to_account: wallet/card, to_user_id: 1, password: 'password' }
class User::Wallet::Credit < User::Wallet::Base
  attr_accessor :from_user, :to_user, :from_account, :to_account, :amount, :to_user_payment, :from_user_payment

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
    end
  end

  def init
    super
    self.amount= params[:amount].to_i rescue nil
    self.from_account = params[:from_account].to_sym rescue nil
    self.to_account = params[:to_account].to_sym rescue nil
    self.from_user = user
    self.to_user = params[:to_user]
    if to_user.blank? and params[:to_user_id].present?
      op= User::Team::Index.new(user, params)
      users = op.run
      self.to_user = (users.with_id(params[:to_user_id]).first rescue nil) if op.success? and users.present?
    end
  end

  def validate
    super
    if self.amount.blank?
      add_message :error, 'Amount cannot be blank'
    end
    if from_user.blank? or to_user.blank?
      add_message :error, 'User not found'
    end
    if from_account.blank? or to_account.blank?
      add_message :error, 'Account cannot be blank'
    end
    return if has_errors?
    if to_account == :card and to_user.cards.blank?
      add_message :error, 'User is not associated with a card to initiate this transfer'
      return
    end
    if from_account == :wallet and from_user.wallet.balance_value < self.amount
      add_message :error, 'Insufficient funds to initiate the transfer'
    end
    unless (from_account == :virtual_account or from_account == :wallet) and (to_account == :card or to_account == :wallet)
      add_message :error, 'Invalid Request'
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
  end

  def process

    case from_account
      when :virtual_account
        payment_attributes = {}
        payment_attributes[:initiating_user] = from_user
        payment_attributes[:receiving_user] = to_user
        payment_attributes[:date] = Date.today
        payment_attributes[:note] = params[:note]
        payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

        if to_account == :wallet

          if to_user.wallet.add_funds(self.amount)
            user.company.account.funds_credited_to_wallet(self.amount)

            payment_attributes[:payment_type_id] = PaymentType.id_for(:receive_credit_from_virtual_account_to_wallet)
            self.to_user_payment = to_user.payments.create payment_attributes
          else
            add_message :error, to_user.wallet.errors.full_messages
          end

        elsif to_account == :card

          credit_presenter = ItzCash::Credit.(to_user, params)
          unless credit_presenter.success?
            add_message :error, credit_presenter.messages[:error]
            return
          end
          payment_attributes[:payment_type_id] = PaymentType.id_for(:receive_credit_from_virtual_account_to_card)
          self.to_user_payment =to_user.payments.create payment_attributes

        end
      when :wallet
        payment_from_attributes = {}
        payment_from_attributes[:initiating_user] = to_user
        payment_from_attributes[:receiving_user] = from_user
        payment_from_attributes[:date] = Date.today
        payment_from_attributes[:note] = params[:note]
        payment_from_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

        payment_to_attributes = {}
        payment_to_attributes[:initiating_user] = from_user
        payment_to_attributes[:receiving_user] = to_user
        payment_to_attributes[:date] = Date.today
        payment_to_attributes[:note] = params[:note]
        payment_to_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
        if to_account == :wallet

          if from_user.wallet.subtract_funds(self.amount)
            to_user.wallet.add_funds(self.amount)
            payment_from_attributes[:payment_type_id] = PaymentType.id_for(:initiate_credit_from_wallet_to_wallet)
            self.from_user_payment =from_user.payments.create payment_from_attributes

            payment_to_attributes[:payment_type_id] = PaymentType.id_for(:receive_credit_from_wallet_to_wallet)
            self.to_user_payment =to_user.payments.create payment_to_attributes
          else
            add_message :error, from_user.wallet.errors.full_messages
          end

        elsif to_account == :card

          credit_presenter = ItzCash::Credit.(to_user, params)
          if credit_presenter.success?
            from_user.wallet.subtract_funds(self.amount)

            payment_from_attributes[:payment_type_id] = PaymentType.id_for(:initiate_credit_from_wallet_to_card)
            self.from_user_payment =from_user.payments.create payment_from_attributes

            payment_to_attributes[:payment_type_id] = PaymentType.id_for(:receive_credit_from_wallet_to_card)
            self.to_user_payment =to_user.payments.create payment_to_attributes

          else
            add_message :error, credit_presenter.messages[:error]
          end

        end
    end
  end

  def success
    params[:to_user_payment] = self.to_user_payment
    params[:from_user_payment] = self.from_user_payment
    User::Wallet::Credit::SuccessPresenter.new(user, params, messages)
  end

  class User::Wallet::Credit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :to_user_payment, :from_user_payment

    def init
      self.from_user_payment = params[:from_user_payment]
      self.to_user_payment = params[:to_user_payment]
    end
  end

end