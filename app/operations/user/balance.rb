class User::Balance < User::Base
  attr_accessor :selected_user, :require_card_balance, :balances

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.params= {} if params.blank?
    if params[:used_id].present? or params[:id].present?
      user_id = (params[:used_id] or params[:id])
      self.selected_user = User::Index.(user, params).team.with_id(user_id).first rescue nil
    else
      self.selected_user = user
    end
    self.require_card_balance = true
    self.require_card_balance = params[:require_card_balance] unless params[:require_card_balance].nil?
  end

  def validate
    if selected_user.blank?
      add_message :error, 'User not found'
    end
  end

  def process
    self.balances={}
    if selected_user.company_admin?
      self.balances[:virtual_account] = Company::VirtualAccount::Balance.(selected_user).balance rescue nil
    end
    self.balances[:wallet] = User::Wallet::Balance.(user, for_user: selected_user)
    self.balances[:card] = User::PrepaidCard::Show.(user, user: selected_user).balance rescue nil if require_card_balance
    self.balances[:cash_in_hand] = selected_user.balance_sheet.cash_in_hand.value rescue nil
    self.balances[:pending_reimbursement] = selected_user.balance_sheet.pending_reimbursement.value
    self.balances[:pending_advance_request] = selected_user.balance_sheet.pending_advance.value
  end

  def success
    User::Balance::SuccessPresenter.new(user, {selected_user: selected_user, balances: self.balances}, messages)
  end

  class User::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_user, :balances

    def init
      self.selected_user = params[:selected_user]
      self.balances = params[:balances]
    end

  end

end