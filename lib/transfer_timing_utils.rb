class TransferTimingUtils

  def self.within_timeframe?(payment_mode = nil, date = nil)
    if date.nil?
      date = DateUtils.local_date
    elsif date.class.name == String.name
      date = DateUtils.parse_date date
    end
    if date <= Date.today
      date = DateTime.now
    else
      date.change(hour: 8, min: 1, sec: 0)
    end
    case payment_mode&.upcase
      when "IMPS"
        return true
      when "NEFT", "RTGS"
        return false if (date.sunday?)
        return false if bank_holidays.include?(date.strftime("%d-%m-%Y"))
        return daily_time_range(payment_mode).cover?(date) # i.e. if the timestamp
      else
        return false
    end
  end

  # 2019's list. Will have to be updated every year
  def self.bank_holidays
    %w(
        26-01-2018
        27-01-2018
        13-02-2018
        19-02-2018
        02-03-2018
        29-03-2018
        30-03-2018
        14-04-2018
        01-05-2018
        16-06-2018
        02-07-2018
        15-08-2018
        17-08-2018
        22-08-2018
        08-09-2018
        13-09-2018
        20-09-2018
        22-09-2018
        02-10-2018
        13-10-2018
        18-10-2018
        27-10-2018
        07-11-2018
        08-11-2018
        10-11-2018
        21-11-2018
        23-11-2018
        24-11-2018
        08-12-2018
        22-12-2018
        25-12-2018
    )
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

  def self.next_valid_date(date, payment_mode)
    # date = date
    if date.blank?
      date = DateTime.now
    end
    return date.to_date if within_timeframe? payment_mode, date
    return date.to_date if payment_mode == "IMPS"
    case payment_mode.upcase
      when "NEFT", "RTGS"
        date = date.to_date
        next_date = date + 1.day # i.e. the next day
        loop do
          if bank_holidays.include?(next_date.strftime("%d-%m-%Y")) || next_date.sunday?
            next_date = next_date + 1.day
          else
            return next_date
          end
        end
      else
        # do nothing? maybe just return the original date
        return date.to_date
    end
  end

end