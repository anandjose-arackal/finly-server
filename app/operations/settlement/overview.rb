class Settlement::Overview < Settlement::Base
  attr_accessor :reports_summary, :money_requests_summary, :users_summary, :currency_id

  class Settlement::Overview::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports_summary, :money_requests_summary, :users_summary

    def init
      self.reports_summary = params[:reports_summary]
      self.money_requests_summary = params[:money_requests_summary]
      self.users_summary = params[:users_summary]
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
    load_reports_summary
    load_money_requests_summary
    load_users_summary
  end

  def success
    params[:reports_summary] = self.reports_summary
    params[:money_requests_summary] = self.money_requests_summary
    params[:users_summary] = self.users_summary
    Settlement::Overview::SuccessPresenter.new(user, params, messages)
  end

  protected

  def load_reports_summary
    reports_presenter = Report::Index.(user, params)
    unless reports_presenter.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    reports = reports_presenter.reports.approved
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
    money_requests = money_requests_presenter.money_requests.approved
    self.money_requests_summary = {
        count: money_requests.count,
        total: Amount.new(value: money_requests.total_value, currency_id: self.currency_id),
        user_count: money_requests.pluck(:user_id).uniq.count
    }
  end

  def load_users_summary
    users_presenter = User::Index.(user, params)
    unless users_presenter.success?
      add_message :error, users_presenter.errors.full_messages
    end
    users = users_presenter.team
    self.users_summary = {
        count: users.count
    }
  end

end