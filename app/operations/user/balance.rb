class User::Balance < User::Base
  attr_accessor :target_user, :balances, :cards

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
    if self.target_user.blank? and (params[:target_user_id].present? or params[:user_id].present? or params[:id].present?)
      user_id = (params[:target_user_id] or params[:user_id] or params[:id])
      if user_id.to_i == user.id
        self.target_user = user
      else
        self.target_user = User::Index.(user, params).team.with_id(user_id).first rescue nil
      end
    end
  end

  def validate
    if target_user.blank? and (params[:target_user_id].present? or params[:user_id].present? or params[:id].present? or
        params[:target_user].present? or params[:user].present?)
      add_message :error, 'User not found'
    end
  end

  def process
    current_user_card_assigned = false
    current_user_card_assigned = user.cards.present? if user.present?

    self.balances={}
    self.cards = {}

    # Virtual Account
    if params[:virtual_account] and user.company_admin?
      op = Company::VirtualAccount::Balance.(user)
      self.balances[:virtual_account] = {balance: op.balance} rescue nil
    end

    # Wallet
    self.balances[:current_user_wallet] = {balance: User::Wallet::Balance.(user)} if params[:current_user_wallet] or params[:current_user_all]

    # Card
    if current_user_card_assigned and (params[:current_user_card] or params[:current_user_all])
      self.cards[:current_user_card] = []

      self.user.cards.each do |card|
        item = {}
        presenter = User::PrepaidCard::Show.(user, user: user, card_id: card.id)
        item[:card] = card
        item[:program] = {id: card.card_program_id, name: card.card_program.name, view_balance: true, view_eligibility: true}
        item[:balance] = presenter.balance rescue nil
        item[:eligibility] = presenter.available_card_eligibility rescue nil
        self.cards[:current_user_card] << item
      end

    end

    # Cash In Hand
    self.balances[:current_user_cash_in_hand] = user.balance_sheet.cash_in_hand.amount_value rescue nil if params[:current_user_cash_in_hand] or params[:current_user_all]

    # Pending Cash Advance
    self.balances[:current_user_pending_money_request] = user.balance_sheet.pending_advance.amount_value if params[:current_user_pending_money_request] or params[:current_user_all]

    # pending approved reports
    if params[:current_user_pending_reports] or params[:current_user_all]
      self.balances[:current_user_approved_reports] = user.reports.approved.count
      self.balances[:current_user_pending_reports_total] = 0
      user.reports.approved.each do |report|
        balances[:current_user_pending_reports_total] += report.total_amount(:only_manual_expenses)
      end
    end

    if target_user.present?
      target_user_card_assigned = false
      target_user_card_assigned = target_user.cards.present? if target_user.present?

      # Wallet
      self.balances[:target_user_wallet] = {balance: User::Wallet::Balance.(user, for_user: target_user)} if params[:target_user_wallet] or params[:target_user_all]

      # Card
      if target_user_card_assigned and (params[:target_user_card] or params[:target_user_all])
        self.cards[:target_user_card] = []

        self.target_user.cards.each do |card|
          item = {}
          view_balance = user.id == target_user.id ? true : card.card_program.manager_view_balance
          view_eligibility = user.id == target_user.id ? true : card.card_program.manager_view_eligibility
          item[:card] = card
          item[:program] = {id: card.card_program_id, name: card.card_program.name, view_balance: view_balance, view_eligibility: view_eligibility}
          if view_eligibility or view_balance
            presenter = User::PrepaidCard::Show.(user, user: target_user, card_id: card.id)
            item[:balance] = presenter.balance rescue nil if view_balance
            item[:eligibility] = presenter.available_card_eligibility rescue nil if view_eligibility
          end
          self.cards[:target_user_card] << item
        end
      end

      # Cash In Hand
      self.balances[:target_user_cash_in_hand] = target_user.balance_sheet.cash_in_hand.amount_value rescue nil if params[:target_user_cash_in_hand] or params[:target_user_all]

      # Pending Cash Advance
      self.balances[:target_user_pending_money_request] = target_user.balance_sheet.pending_advance.amount_value if params[:target_user_pending_money_request] or params[:target_user_all]

      # pending approved reports
      if params[:target_user_pending_reports] or params[:target_user_all]
        self.balances[:target_user_approved_reports] = target_user.reports.approved.count
        self.balances[:target_user_pending_reports_total] = 0
        target_user.reports.approved.each do |report|
          balances[:target_user_pending_reports_total] += report.total_amount(:only_manual_expenses)
        end
      end
    end

  end

  def success
    User::Balance::SuccessPresenter.new(user, {target_user: target_user, balances: self.balances, cards: self.cards}, messages)
  end

  class User::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :target_user, :balances, :cards

    def init
      self.target_user = params[:target_user]
      self.balances = params[:balances]
      self.cards = params[:cards]
    end

  end

end
