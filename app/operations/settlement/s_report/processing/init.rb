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
    else
      add_message :error, 'Invalid Payment Type'
    end
  end

  def validate
    if self.reports.blank?
      add_message :error, 'Report not found'
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
    self.reports = reports_presenter.reports.approved.include_reimbursable_user_accounts
    if not params&.dig(:init_all) and params&.dig(:report_id).present?
      self.reports = self.reports.with_id(params&.dig(:report_id))
    end


    self.user_reports = []
    self.reimbursement_total = {}
    self.expenses_total = {}
    self.user_count = 0

    user_ids = self.reports.pluck(:user_id).uniq
    users_map = User.with_id(user_ids).index_by(&:id)
    user_ids.each do |user_id|
      self.user_count += 1

      # Map which is of the format {currency_id1:[*report_ids*], currency_id2: [*report_ids*]}
      report_currency_map = {}
      user_reports = self.reports.with_user(user_id)
      user_reports.includes_policy.map do |report|
        if report_currency_map[report.policy.settlement_currency].nil?
          report_currency_map[report.policy.settlement_currency] = []
        end
        report_currency_map[report.policy.settlement_currency] << report.id
      end
      report_currency_map.each do |settlement_currency, report_ids|
        settlement_currency_code = settlement_currency.country_code
        currency_reports = user_reports.with_id(report_ids)
        currency_report_ids = currency_reports.pluck(:id)
        expenses = Expense.with_report_id(currency_report_ids).sum_amount(settlement_currency_code)
        reimbursements = Expense.with_report_id(currency_report_ids).sum_reimbursements(settlement_currency_code)

        self.reimbursement_total[settlement_currency_code] = Amount.new(value: 0, currency: settlement_currency) if self.reimbursement_total[settlement_currency_code].nil?
        self.reimbursement_total[settlement_currency_code].value += expenses
        self.expenses_total[settlement_currency_code] = Amount.new(value: 0, currency: settlement_currency) if self.expenses_total[settlement_currency_code].nil?
        self.expenses_total[settlement_currency_code].value += reimbursements

        self.user_reports << {
            user: users_map[user_id],
            expenses_total: Amount.new(value: expenses, currency: settlement_currency),
            reimbursement_total: Amount.new(value: reimbursements, currency: settlement_currency),
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