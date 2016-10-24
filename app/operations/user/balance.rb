class User::Balance < User::Base
  attr_accessor :target_user, :balances

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Nothing to load'
    end
  end

  def init
    if params[:target_user_id].present? or params[:user_id] or params[:id].present?
      user_id = (params[:target_user_id] or params[:user_id] or params[:id])
      self.target_user = User::Index.(user, params).team.with_id(user_id).first rescue nil
    end
  end

  def validate
    # if target_user.blank?
    #   add_message :error, 'User not found'
    # end
  end

  def process
    self.balances={}

    # Virtual Account
    self.balances[:virtual_account] = Company::VirtualAccount::Balance.(user).balance rescue nil if params[:virtual_account] and user.company_admin?

    # Wallet
    self.balances[:target_user_wallet] = User::Wallet::Balance.(user, for_user: target_user) if params[:target_user_wallet]
    self.balances[:current_user_wallet] = User::Wallet::Balance.(user) if params[:current_user_wallet]

    # Card
    self.balances[:target_user_card] = User::PrepaidCard::Show.(user, user: target_user).balance rescue nil if params[:target_user_card]
    self.balances[:current_user_card] = User::PrepaidCard::Show.(user, user: user).balance rescue nil if params[:current_user_card]

    # Cash In Hand
    self.balances[:target_user_cash_in_hand] = target_user.balance_sheet.cash_in_hand.value rescue nil if params[:target_user_cash_in_hand]
    self.balances[:current_user_cash_in_hand] = user.balance_sheet.cash_in_hand.value rescue nil if params[:current_user_cash_in_hand]

    # Pending Reimbursement
    self.balances[:target_user_pending_reimbursement] = target_user.balance_sheet.pending_reimbursement.value if params[:target_user_pending_reimbursement]
    self.balances[:current_user_pending_reimbursement] = user.balance_sheet.pending_reimbursement.value if params[:current_user_pending_reimbursement]

    # Pending Cash Advance
    self.balances[:target_user_pending_advance_request] = target_user.balance_sheet.pending_advance.value if params[:target_user_pending_advance_request]
    self.balances[:current_user_pending_advance_request] = user.balance_sheet.pending_advance.value if params[:current_user_pending_advance_request]

  end

  def success
    User::Balance::SuccessPresenter.new(user, {target_user: target_user, balances: self.balances}, messages)
  end

  class User::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :target_user, :balances

    def init
      self.target_user = params[:target_user]
      self.balances = params[:balances]
    end

  end

end