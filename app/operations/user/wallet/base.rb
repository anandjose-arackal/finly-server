class User::Wallet::Base < BaseOperation

  # ACTIONS = {credit_from_virtual_account_to_wallet: 1, credit_from_wallet_to_wallet: 2,
  #            credit_from_wallet_to_card: 3, credit_from_virtual_account_to_card: 4,
  #            debit_from_wallet_to_wallet: 5, debit_from_wallet_to_virtual_account: 6}

  ACTIONS = {credit: 1, debit: 2}

  def pre_validate
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
  end

end