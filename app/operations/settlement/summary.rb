class Settlement::Summary < Settlement::Base
  attr_accessor :reports_summary, :money_requests_summary, :users_summary, :currency_id,
                :finly_money_summary, :cash_on_hand_summary, :expense_cards_summary,
                :reimbursement_cards_summary, :cards_enabled, :bank_transfer_enabled

  class Settlement::Summary::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports_summary, :money_requests_summary, :users_summary, :finly_money_summary,
                  :cash_on_hand_summary, :expense_cards_summary, :reimbursement_cards_summary,
                  :cards_enabled, :bank_transfer_enabled

    def init
      self.reports_summary = params[:reports_summary]
      self.money_requests_summary = params[:money_requests_summary]
      self.users_summary = params[:users_summary]
      self.cash_on_hand_summary = params[:cash_on_hand_summary]
      self.finly_money_summary = params[:finly_money_summary]
      self.expense_cards_summary = params[:expense_cards_summary]
      self.reimbursement_cards_summary = params[:reimbursement_cards_summary]
    end

  end

  def authorized_user_types
    [:admin, :manager, :finance_manager, :auditor]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.currency_id = Currency.id_for(:INR)
    self.cards_enabled = user.company.cards_enabled?
    self.bank_transfer_enabled = user.company.bank_reimbursement_enabled?

    load_reports_summary
    load_money_requests_summary

    users_presenter = User::Index.(user, params)
    unless users_presenter.success?
      add_message :error, users_presenter.messages[:error]
      return
    end
    users = users_presenter.team
    user_ids = users.pluck(:id)
    load_users_summary(users)
    load_cash_on_hand_summary(user_ids)

    if cards_enabled or bank_transfer_enabled
      load_finly_money_summary(user_ids)
    end
    if cards_enabled
      load_expense_cards_summary(user_ids)
      load_reimbursement_cards_summary(user_ids)
    end
  end

  def success
    params[:reports_summary] = self.reports_summary
    params[:money_requests_summary] = self.money_requests_summary
    params[:users_summary] = self.users_summary
    params[:cash_on_hand_summary] = self.cash_on_hand_summary
    params[:finly_money_summary] = self.finly_money_summary
    params[:expense_cards_summary] = self.expense_cards_summary
    params[:reimbursement_cards_summary] = self.reimbursement_cards_summary
    Settlement::Summary::SuccessPresenter.new(user, params, messages)
  end

  protected

  def load_reports_summary
    reports_presenter = Reports::Index.(user, params)
    unless reports_presenter.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    reports = reports_presenter.reports.approved.without_associated_processor
    self.reports_summary = {
        count: reports.count,
        expenses_total: Amount.new(value: reports.expenses_total, currency_id: self.currency_id),
        reimbursement_total: Amount.new(value: reports.expenses_reimbursable_total, currency_id: self.currency_id),
        user_count: reports.pluck(:user_id).uniq.count
    }
  end

  def load_money_requests_summary
    money_requests_presenter = Object.const_get('MoneyRequest::Index').(user, params)
    unless money_requests_presenter.success?
      add_message :error, money_requests_presenter.messages[:error]
      return
    end
    money_requests = money_requests_presenter.money_requests.approved.without_associated_processor
    self.money_requests_summary = {
        count: money_requests.count,
        total: Amount.new(value: money_requests.total_value, currency_id: self.currency_id),
        user_count: money_requests.pluck(:user_id).uniq.count
    }
  end

  def load_users_summary(users)
    self.users_summary = {
        active: users.active.count,
        pending: users.pending.count,
        inactive: users.inactive.count
    }
  end

  def load_cash_on_hand_summary(user_ids)
    self.cash_on_hand_summary = {
        card_transfer_wallet: Amount.new(value: CashOnHand.with_user(user_ids).sum_balance, currency_id: self.currency_id),
        pockets_count: UserPocket.with_user_id(current_company.users.pluck(:id)).count
    }
  end

  def load_finly_money_summary(user_ids)
    return nil unless cards_enabled or bank_transfer_enabled
    self.finly_money_summary = {}
    if cards_enabled
      self.finly_money_summary[:card_transfer_wallet] = Amount.new(value: UserWallet.with_user(user_ids).sum_balance, currency_id: self.currency_id)
    else
      self.finly_money_summary[:card_transfer_wallet] = nil
    end
    if bank_transfer_enabled
      self.finly_money_summary[:bank_transfer_wallet] = Amount.new(value: VendorPaymentWallet.with_user(user_ids).sum_balance, currency_id: self.currency_id)
    else
      self.finly_money_summary[:bank_transfer_wallet] = nil
    end
  end

  def load_expense_cards_summary(user_ids)
    expense_cards = Card.with_user(user_ids).expense_cards
    self.expense_cards_summary = {
        count: expense_cards.count,
        total: Amount.new(value: expense_cards.sum_balance, currency_id: self.currency_id)
    }
  end

  def load_reimbursement_cards_summary(user_ids)
    reimbursement_cards = Card.with_user(user_ids).reimbursement_cards
    self.reimbursement_cards_summary = {
        count: reimbursement_cards.count,
        # total: Amount.new(value: reimbursement_cards.sum_balance, currency_id: self.currency_id)
    }
  end

end