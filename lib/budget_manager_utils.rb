class BudgetManagerUtils

  # this method will return the next date for a given start date and given period
  def self.next_date(start_date, end_date, period_id)
    period = Period.find_by(id: period_id)
    return nil if period.blank?

    start_date = Date.parse(start_date) if start_date.is_a?(String)
    if period.quarter?
      end_date_generated = start_date + 91.days # because there is not default ruby method for "next quarter"
    else
      end_date_generated = start_date + 1.send(period.name.downcase) - 1.day
    end
    return end_date_generated > end_date ? end_date : end_date_generated
  end
end