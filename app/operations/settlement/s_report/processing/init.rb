class Settlement::SReport::Processing::Init < Settlement::SReport::Processing::Base
  attr_accessor :payment_type, :reports, :user_reports, :expenses_total, :reimbursement_total, :user_count

  class Settlement::SReport::Processing::Init::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :details, :expenses_total, :reimbursement_total, :user_count

    def init
      self.details = params[:details]
      self.expenses_total = params[:expenses_total]
      self.reimbursement_total = params[:reimbursement_total]
      self.user_count = params[:user_count]
    end

  end

  def authorized_user_types
    [:admin, :finance_manager]
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
    if params&.dig(:payment_type).blank?
      add_message :error, 'Payment Type not found'
      return
    end
    if params[:payment_type] == 'payment_file'
      result = PaymentFiles::IsConfigured.(user, params)
      unless result.success?
        add_message :error, result.messages[:error]
        return
      end
    end
  end

  def init
    self.payment_type = params[:payment_type]
    init_reports
    return if has_errors?
    case self.payment_type
    when 'payment_file'
      init_bank_transfer
    when 'bank_transfer'
      validate_inr_currency and (return if has_errors?)
      init_bank_transfer
    when 'reimbursement_card'
      validate_inr_currency and (return if has_errors?)
      init_reimbursement_card
    when 'outside_finly'
      init_outside_finly
    when 'mark_as_closed'
      # ladies and gentlemen, report is ordered to be closed.
      # this is all we will do here.
    else
      add_message :error, 'Invalid Payment Type'
    end
  end

  def validate
    if self.reports.blank?
      add_message :error, 'Report not found'
    end

    if self.reports.pluck(:report_processor_group_mapping_id).compact.present?
      ids = self.reports.where.not(report_processor_group_mapping_id: nil).pluck(:id).join(", ")
      add_message :error, "Reports with ID #{ids} already linked to a batch"
      return
    end
  end

  # Settlement can only be done against a single currency unless outside Finly or mark as settled
  def validate_inr_currency
    policy_ids = self.reports.pluck(:policy_id)
    if Policy.with_id(policy_ids).without_settlement_currency_id(Currency.id_for(:INR)).present?
      add_message :error, 'You cannot process non-INR currency with the selected method'
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
    reports_presenter = Reports::Index.(user, params)
    unless reports_presenter&.success?
      message = reports_presenter&.messages[:error] || 'Unknown error'
      add_message :error, message
      return
    end
    self.reports = reports_presenter.reports.approved.not_settled.includes(trails: :action_user)
    if not params&.dig(:init_all) and params&.dig(:report_id).present?
      self.reports = self.reports.with_id(params&.dig(:report_id))
    end


    self.user_reports = []
    self.reimbursement_total = {}
    self.expenses_total = {}

    user_ids = self.reports.pluck(:user_id).uniq
    report_ids = self.reports.pluck(:id).uniq
    all_report_associated_expenses = Expense.where(report_id: report_ids)
    grouped_reports = self.reports.group_by(&:user_id)
    self.user_count = grouped_reports.keys.size
    grouped_reports.each do |key, reports_array|
      report_currency_map = reports_array.group_by{|report|  report.policy.settlement_currency.country_code}
      report_currency_map.each do |settlement_currency_code, currency_report_array|
        report_ids = currency_report_array.pluck(:id)
        currency_reports = reports.with_id(report_ids)
        currency_report_ids = currency_reports.pluck(:id)
        expenses = all_report_associated_expenses.with_report_id(currency_report_ids).sum_amount(settlement_currency_code)
        reimbursements = all_report_associated_expenses.with_report_id(currency_report_ids).sum_reimbursements(settlement_currency_code)
        self.reimbursement_total[settlement_currency_code] = Amount.new(value: 0, currency: settlement_currency) if self.reimbursement_total[settlement_currency_code].nil?
        self.reimbursement_total[settlement_currency_code].value += reimbursements
        self.expenses_total[settlement_currency_code] = Amount.new(value: 0, currency: settlement_currency) if self.expenses_total[settlement_currency_code].nil?
        self.expenses_total[settlement_currency_code].value += expenses
        self.user_reports << {
            user: currency_reports.first.user,
            expenses_total: Amount.new(value: expenses, currency: Currency.currency_for(settlement_currency_code)),
            reimbursement_total: Amount.new(value: reimbursements, currency: Currency.currency_for(settlement_currency_code)),
            reports: currency_reports,
            has_errors: false
        }
      end
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