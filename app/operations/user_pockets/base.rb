class UserPockets::Base < BaseOperation

  attr_accessor :pocket, :amount, :selected_user, :payment_parameters

  def pre_validate
    if params[:payment][:amount].blank? or params[:payment][:amount].to_d <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
    end
  end

  def init
    id = params[:selected_user_id]
    team = User::Team::Index.(user, params)
    self.selected_user = team.with_id(id).first rescue nil if team.present?
    pocket_id = params[:id] || params[:user_pocket_id]
    self.pocket = self.selected_user.user_pockets.find_by(id: pocket_id)

    self.amount = payment_params[:amount]
  end

  def validate
    if self.pocket.blank?
      add_message :error, "User Pocket not found"
      return
    end
  end

  def init_payment_request

  end

  protected

  def payment_params
    params.require(:payment).permit(:amount, :note, :date,
                                    :currency_id, :total, :initiating_account_id, :initiating_account_type,
                                    :receiving_account_type, :receiving_account_id, :payment_mode)
  end

  def retrieve_initiating_account(account_type)
    case account_type
      when 1, '1' # i.e. finly money
        return user.bank_wallet
      when 2, '2' # i.e. company credits
        return user.company.yes_bank_company_account
      when 3, '3' # i.e. outside Finly
        return nil
      else
        # do nothing?
    end
  end

  def retrieve_receiving_account(account_type, account_id)
    case account_type
      when 1, '1' # i.e. user's bank account
        id = payment_param[:receiving_account_id]
        return selected_user.bank_accounts.find_by(id: id)
      when 2, '2' # i.e. outside of Finly
        return selected_user.user_pockets.find_by(id: account_id)
      else
        # do nothing?
    end
  end

end