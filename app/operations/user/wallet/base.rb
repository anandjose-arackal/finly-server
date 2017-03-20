class User::Wallet::Base < BaseOperation
  attr_accessor :initiating_user, :initiating_account, :initiating_account_type, :initiating_account_id,
                :receiving_user, :receiving_account, :receiving_account_type, :receiving_account_id,
                :amount, :payment

  ACTIONS = {credit: 1, debit: 2}

  def authorized_user_types
    if params.present? and params[:initiating_account_type].present? and params[:receiving_account_type].present?
      if params[:initiating_account_type].to_sym == :virtual_account or params[:receiving_account_type].to_sym == :virtual_account
        return :company_admin
      elsif params[:initiating_account_type].to_sym == :wallet and params[:receiving_account_type].to_sym == :wallet
        return [:admin, :manager, :finance_manager]
      end
    end
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    if params.blank? or params[:initiating_account_type].blank? or params[:receiving_account_type].blank? or
        (params[:receiving_user].blank? and params[:receiving_user_id].blank?)
      add_message :error, 'Invalid request'
      return
    end
    if params[:initiating_account_type] == :card and params[:initiating_account_id].blank?
      add_message :error, 'Card not found'
      return
    end
    if params[:receiving_account_type] == :card and params[:receiving_account_id].blank?
      add_message :error, 'Card not found'
    end
  end

  def init
    super
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:amount].blank?
      add_message :error, 'Amount cannot be blank'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password!'
    end

    self.amount= params[:amount].to_d rescue nil

    self.initiating_user = user
    self.receiving_user = params[:receiving_user]
    if receiving_user.blank? and params[:receiving_user_id].present?
      if params[:receiving_user_id].to_i == user.id
        self.receiving_user = user
      else
        users = User::Team::Index.(user, params)
        self.receiving_user = (users.with_id(params[:receiving_user_id]).first rescue nil) if users.present?
      end
    end

    self.initiating_account_type = params[:initiating_account_type].to_sym rescue nil
    self.initiating_account_id = params[:initiating_account_id]

    if initiating_user.present?
      case self.initiating_account_type
        when Payment::AccountType::VIRTUAL_ACCOUNT
          self.initiating_account = initiating_user.company
        when Payment::AccountType::WALLET
          self.initiating_account = initiating_user.wallet
        when Payment::AccountType::Card
          if initiating_account_id.present?
            self.initiating_account = initiating_user.cards.with_id(initiating_account_id).first rescue nil
          end
      end
    end

    self.receiving_account_type = params[:receiving_account_type].to_sym rescue nil
    self.receiving_account_id = params[:receiving_account_id]
    if receiving_user.present?
      case self.receiving_account_type
        when Payment::AccountType::VIRTUAL_ACCOUNT
          self.receiving_account = receiving_user.company
        when Payment::AccountType::WALLET
          self.receiving_account = receiving_user.wallet
        when Payment::AccountType::Card
          if receiving_account_id.present?
            self.receiving_account = receiving_user.cards.with_id(receiving_account_id).first rescue nil
          end
      end
    end

  end

  def validate
    super
    if self.amount.blank?
      add_message :error, 'Amount cannot be blank'
    end
    if initiating_user.blank? or receiving_user.blank?
      add_message :error, 'User not found'
    end
    if initiating_account_type.blank? or receiving_account_type.blank?
      add_message :error, 'Account not found'
    end
    if initiating_account.blank? or receiving_account.blank?
      add_message :error, 'Error in request. Cannot initiate this transfer'
    end
    return if has_errors?
    validate_sufficient_funds
  end

end