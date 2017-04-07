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
    total_cash_amount = report.total_amount(:only_manual_expenses) + report.total_amount(:only_distance_expenses) + report.total_amount(:only_time_expenses) + report.total_amount(:only_per_diem_expenses)

    total_card_amount = report.total_amount(:only_card_expenses)
    currency = Currency.first
    balance_sheet.add_approved_reports_total total_cash_amount, currency

    # adding report's total cash amount
    if report.cash_expenses_total.blank?
      cash_amount = Amount.new(value: total_cash_amount, currency: Currency.first)
      unless cash_amount.save
        messages[:error] = cash_amount.errors.full_messages
        return
      end
      unless report.update_attributes(cash_expenses_total: cash_amount)
        messages[:error] = report.errors.full_messages
        return
      end
    else
      cash_amount = report.cash_expenses_total
      unless cash_amount.update_attributes(value: total_cash_amount, currency: Currency.first)
        messages[:error] = report_amount.errors.full_messages
        return
      end
    end

    # adding reports total card amount
    if report.card_expenses_total.blank?
      card_amount = Amount.new(value: total_card_amount, currency: Currency.first)
      unless card_amount.save
        messages[:error] = card_amount.errors.full_messages
        return
      end
      unless report.update_attributes(card_expenses_total: card_amount)
        messages[:error] = report.errors.full_messages
        return
      end
    else
      card_amount = report.card_expenses_total
      unless card_amount.update_attributes(value: total_card_amount, currency: Currency.first)
        messages[:error] = card_amount.errors.full_messages
        return
      end
    end

    unless report.save
      messages[:error] = report.errors.full_messages
    end
  end

  def post_process

  end

  def success
    report
  end

end