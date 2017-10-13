class TransferTimingUtils

  def self.within_timeframe?(payment_mode = nil)
    case payment_mode&.upcase
      when "IMPS"
        return true
      when "NEFT", "RTGS"
        return false if (DateUtils.local_date.sunday? || DateUtils.local_date.saturday?)
        return false if bank_holidays.include?(DateUtils.local_date.strftime("%d-%m-%Y"))
        return daily_time_range(payment_mode).cover?(DateUtils.local_date_time)
      else
        return false
    end
  end

  # 2017's list. Will have to be updated every year
  def self.bank_holidays
    [
        '14-10-2017',
        '28-10-2017',
        '11-11-2017',
        "25-11-2017",
        "9-12-2017",
        "23-12-2017",
        '25-12-2017',
        "13-01-2018",
        '26-01-2018',
        "27-01-2018"
    ]
  end

  def self.daily_time_range(payment_mode)
    # todo check if the timezone is actually the current one
    start_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 8, 0, 0, "IST")
    case payment_mode
      when "NEFT"
        end_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 18, 30, 0, "IST")
      when "RTGS"
        end_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 16, 10, 0, "IST")
      else
        # defaulting to RTGS times just to be sure
        end_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 16, 10, 0, "IST")
    end
    (start_time..end_time)
  end

end