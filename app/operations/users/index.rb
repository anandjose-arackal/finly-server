#NOT BEING USED. REMOVE THIS WHEN YOU START USING IT

class Users::Index < Users::Base
  attr_accessor :users

  def init
    self.users = user.company.users
  end

  def process
    
  end

  def success
    params[:users] = users
    Users::Index::IndexPresenter.new(user, params, messages)
  end

  class Users::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :users, :paginated_users, :count

    has_scope :filter_search
    has_scope :filter_state, type: :array
    has_scope :filter_role, type: :array
    has_scope :filter_reports_awaiting_settlement
    has_scope :filter_pending_money_requests
    has_scope :having_cash_on_hand_balance
    has_scope :having_wallet_balance
    has_scope :with_cards_having_card_program, type: :array
    has_scope :filter_disburse
    has_scope :filter_expense_management
    has_scope :filter_vendor_payments
    has_scope :yes_bank_account_transfer
    has_scope :filter_vendor_payments_reviewers
    has_scope :filter_em_reviewers
    has_scope :filter_unassigned_travel_for_policy
    has_scope :filter_unassigned_finance_for_policy
    has_scope :filter_unassigned_creditor_for_policy
    has_scope :filter_unassigned_members_for_policy

    def init
      self.users = params[:users]

      self.users = apply_scopes(self.users, params)

      per_page = params[:per_page] || 30
      page = params[:page] || 1
      self.paginated_users = users.paginate(page: page, per_page: per_page)
    end
  end

end