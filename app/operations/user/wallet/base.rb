class User::Wallet::Base < BaseOperation

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