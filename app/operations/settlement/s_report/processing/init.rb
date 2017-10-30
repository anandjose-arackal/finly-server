class Settlement::SReport::Processing::Init < Settlement::SReport::Processing::Base
  attr_accessor :payment_mode, :reports, :user_reports, :expenses_total, :reimbursement_total, :user_count

  class Settlement::SReport::Processing::Init::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :details,:expenses_total, :reimbursement_total, :user_count

    def init
      self.details = params[:details]
      self.expenses_total = params[:expenses_total]
      self.reimbursement_total = params[:reimbursement_total]
      self.user_count = params[:user_count]
    end

  end

  def authorized_user_types
    [:admin, :finance_manager, :auditor]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:report_id).blank? and not params&.dig(:init_all)
      add_message :error, 'Report not found'
      return
    end
    if params&.dig(:payment_mode).blank?
      add_message :error, 'Payment Mode not found'
      return
    end
  end

  def init
    self.payment_mode = params[:payment_mode]
    init_reports
    return if has_errors?
    case self.payment_mode
      when 'bank_transfer'
        init_bank_transfer
      when 'reimbursement_card'
        init_reimbursement_card
      when 'outside_finly'
        init_outside_finly
    end
  end

  def validate
    if self.reports.blank?
      add_message :error, 'Report not found'
      return
    end
  end

  def success
    params[:details] = self.user_reports
    params[:expenses_total] = self.expenses_total
    params[:reimbursement_total] = self.reimbursement_total
    params[:user_count] = self.user_count
    Settlement::SReport::Processing::Init::Success.new(user, params, messages)
  end

  protected
  def init_reports
    reports_presenter = Report::Index.(user, params)
    unless reports_presenter&.success?
      message = reports_presenter&.messages[:error] || 'Unknown error'
      add_message :error, message
      return
    end
    self.reports = reports_presenter.reports.include_reimbursable_user_accounts
    expenses_totals = self.reports.group_user.expenses_total
    reimbursable_totals = self.reports.group_user.expenses_reimbursable_total
    self.user_reports = []
    self.reimbursement_total = 0
    self.expenses_total = 0
    self.user_count = 0
    expenses_totals.each do |user, total|
      self.user_count += 1
      self.reimbursement_total += (reimbursable_totals[user] || 0)
      self.expenses_total += total
      user_reports << {
          user: user,
          expenses_total: total,
          reimbursement_total: reimbursable_totals[user],
          reports: self.reports.with_user_id(user.id),
          has_errors: false
      }
    end
  end

  def init_bank_transfer
    self.user_reports.each do |details|
      user = details[:user]
      bank_accounts = user.bank_accounts
      details[:bank_accounts] = bank_accounts
      if bank_accounts.blank?
        details[:has_error] = true
        details[:errors] = 'User has not added a bank account'
        return
      end
    end
  end

  def init_reimbursement_card
    self.user_reports.each do |details|
      user = details[:user]
      cards = user.reimbursement_cards
      details[:reimbursement_cards] = cards
      if cards.blank?
        details[:has_error] = true
        details[:errors] = 'User has not been assigned a Reimbursement Card'
        return
      end
    end
  end

  def init_outside_finly

  end

end