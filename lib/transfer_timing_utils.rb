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

  # 2018's list. Will have to be updated every year
  def self.bank_holidays
    %w(
        26-01-2019
        19-02-2019
        04-03-2019
        21-03-2019
        01-04-2019
        06-04-2019
        13-04-2019
        17-04-2019
        19-04-2019
        01-05-2019
        18-05-2019
        05-06-2019
        01-07-2019
        12-08-2019
        15-08-2019
        17-08-2019
        02-09-2019
        10-09-2019
        02-10-2019
        08-10-2019
        28-10-2019
        12-11-2019
        25-12-2019
        23-02-2019
        09-03-2019
        23-03-2019
        13-04-2019
        27-04-2019
        11-05-2019
        25-05-2019
        08-06-2019
        22-06-2019
        13-07-2019
        27-07-2019
        10-08-2019
        24-08-2019
        14-09-2019
        28-09-2019
        12-10-2019
        26-10-2019
        09-11-2019
        23-11-2019
        14-12-2019
        28-12-2019
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