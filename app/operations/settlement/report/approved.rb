# action that recomputes settlement once a report has been approved
# the user passed must be the report owner, NOT person approving it.
# params:
# report: report being marked as approved
#

class Settlement::Report::Approved < Report::Base
  attr_accessor :report

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve])
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Report not found'
      return
    end
    if user.blank? and not params[:auto_approve]
      add_message :error, 'User not found'
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    if report.accounted?
      messages[:error] << 'Report has already been accounted for'
    end
  end

  def process
    balance_sheet = report.user.balance_sheet
    total_cash_amount = report.total_amount(:only_manual_expenses)
    total_card_amount = report.total_amount(:only_card_expenses)
    currency = Currency.first # todo - temporary until currency is implemented
    cash_expenses_total = total_cash_amount
    balance_sheet.add_approved_reports_total cash_expenses_total, currency
    if report.cash_expenses_total.blank?
      report_amount = Amount.new(value: cash_expenses_total, currency: Currency.first)
      unless report_amount.save
        messages[:error] = report_amount.errors.full_messages
        return
      end
      report.cash_expenses_total = report_amount
    else
      report_amount = report.cash_expenses_total
      report_amount.value = cash_expenses_total
      report_amount.currency = currency
      unless report_amount.save
        messages[:error] = report_amount.errors.full_messages
        return
      end
    end

    report.accounted = true
    report.accounted_at = DateUtils.local_date
    unless report.save
      messages[:error] = report.errors.full_messages
    end
  end

  def post_process
    # mailer
  end

  def success
    report
  end

end