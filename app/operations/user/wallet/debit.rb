
# params = {from_account: :virtual_account/wallet,to_account: wallet/card, to_user_id: 1, password: 'password' }
class User::Wallet::Debit < User::Wallet::Base
  attr_accessor :from_user, :to_user, :from_account, :to_account, :amount

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
    self.from_account = params[:from_account].to_sym rescue nil
    self.to_account = params[:to_account].to_sym rescue nil
    self.to_user = user
    self.from_user = params[:from_user]
    if from_user.blank? and params[:from_user_id].present?
      op= User::Team::Index.new(user, params)
      users = op.run
      self.from_user = (users.with_id(params[:from_user_id]).first rescue nil) if op.success? and users.present?
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
    unless (from_account == :wallet) and (to_account == :virtual_account or to_account == :wallet)
      add_message :error, 'Invalid Request'
    end
  end

  def process

    case from_account
    when :wallet

      if to_account == :wallet
        
        payment_from_attributes = {}
        payment_from_attributes[:initiating_user] = to_user
        payment_from_attributes[:receiving_user] = from_user
        payment_from_attributes[:date] = DateUtils.local_date
        payment_from_attributes[:note] = params[:note]
        payment_from_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

        payment_to_attributes = {}
        payment_to_attributes[:initiating_user] = to_user
        payment_to_attributes[:receiving_user] = from_user
        payment_to_attributes[:date] = DateUtils.local_date
        payment_to_attributes[:note] = params[:note]
        payment_to_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

        if from_user.wallet.subtract_funds(self.amount)
          to_user.wallet.add_funds(self.amount)

          payment_from_attributes[:payment_type_id] = PaymentType.id_for(:receive_debit_from_wallet_to_wallet)
          from_user.payments.create payment_from_attributes

          payment_to_attributes[:payment_type_id] = PaymentType.id_for(:initiate_debit_from_wallet_to_wallet)
          to_user.payments.create payment_to_attributes
        else
          add_message :error, from_user.wallet.errors.full_messages
        end

      elsif to_account == :virtual_account

        payment_attributes = {}
        payment_attributes[:initiating_user] = to_user
        payment_attributes[:receiving_user] = from_user
        payment_attributes[:date] = DateUtils.local_date
        payment_attributes[:note] = params[:note]
        payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}

        if from_user.wallet.subtract_funds(self.amount)
          user.company.account.funds_debited_from_wallet(self.amount)

          payment_attributes[:payment_type_id] = PaymentType.id_for(:initiate_debit_from_wallet_to_virtual_account)
          to_user.payments.create payment_attributes
        else
          add_message :error, to_user.wallet.errors.full_messages
        end

      end
    end
  end

end