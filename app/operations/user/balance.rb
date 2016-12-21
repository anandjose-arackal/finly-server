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
    self.target_user = (params[:target_user] or params[:user])
    if self.target_user.blank? and params[:target_user_id].present? or params[:user_id] or params[:id].present?
      user_id = (params[:target_user_id] or params[:user_id] or params[:id])
      if user_id == user.id
        self.target_user = user
      else
        self.target_user = User::Index.(user, params).team.with_id(user_id).first rescue nil
      end
    end
  end

  def validate
    # if target_user.blank?
    #   add_message :error, 'User not found'
    # end
  end

  def process
    target_user_card_assigned = false
    current_user_card_assigned = false
    target_user_card_assigned = target_user.cards.present? if target_user.present?
    current_user_card_assigned = user.cards.present? if user.present?

    self.balances={}

    # Virtual Account
    self.balances[:virtual_account] = Company::VirtualAccount::Balance.(user).balance rescue nil if params[:virtual_account] and user.company_admin?

    # Wallet
    self.balances[:target_user_wallet] = User::Wallet::Balance.(user, for_user: target_user) if params[:target_user_wallet] or params[:target_user_all]
    self.balances[:current_user_wallet] = User::Wallet::Balance.(user) if params[:current_user_wallet] or params[:current_user_all]
    # debugger
    # Card
    if target_user_card_assigned and (params[:target_user_card] or params[:target_user_all])
      presenter = User::PrepaidCard::Show.(user, user: target_user)
      self.balances[:target_user_card] = presenter.balance rescue nil
      self.balances[:target_user_card_eligibility] = presenter.available_card_eligibility rescue nil
    end
    if current_user_card_assigned and (params[:current_user_card] or params[:current_user_all])
      presenter = User::PrepaidCard::Show.(user, user: user)
      self.balances[:current_user_card] = presenter.balance rescue nil
      self.balances[:current_user_card_eligibility] = presenter.available_card_eligibility rescue nil
    end

    # Cash In Hand
    self.balances[:target_user_cash_in_hand] = target_user.balance_sheet.cash_in_hand.amount_value rescue nil if params[:target_user_cash_in_hand] or params[:target_user_all]
    self.balances[:current_user_cash_in_hand] = user.balance_sheet.cash_in_hand.amount_value rescue nil if params[:current_user_cash_in_hand] or params[:current_user_all]

    # Pending Reimbursement
    self.balances[:target_user_pending_reimbursement] = target_user.balance_sheet.pending_reimbursement.amount_value if params[:target_user_pending_reimbursement] or params[:target_user_all]
    self.balances[:current_user_pending_reimbursement] = user.balance_sheet.pending_reimbursement.amount_value if params[:current_user_pending_reimbursement] or params[:current_user_all]

    # Pending Cash Advance
    self.balances[:target_user_pending_advance_request] = target_user.balance_sheet.pending_advance.amount_value if params[:target_user_pending_advance_request] or params[:target_user_all]
    self.balances[:current_user_pending_advance_request] = user.balance_sheet.pending_advance.amount_value if params[:current_user_pending_advance_request] or params[:current_user_all]

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