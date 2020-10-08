class TransferTimingUtils

  def self.within_timeframe?(payment_mode = nil, date = nil)
    date = date
    if date.nil?
      date = DateUtils.local_date
    elsif date.class.name == String.name
      date = DateUtils.parse_date date
    end
    if date <= Date.today
      date = DateUtils.local_date
    else
      date.change(hour: 8, min: 1, sec: 0)
    end
    return true if date > DateUtils.local_date # because we are only checking for today's payments
    case payment_mode&.upcase
      when "IMPS"
        return true
      when "NEFT"
        return true
      when "RTGS"
        return false if (date.sunday?)
        return false if bank_holidays.include?(date.strftime("%d-%m-%Y"))
        return daily_time_range(payment_mode).cover?(DateUtils.local_date_time) # i.e. if the current time falls into the transferable window
      else
        return false
    end
  end

  # 2019's list. Will have to be updated every year
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
      when "NEFT", "neft"
        start_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 0, 0, 0, "IST")
        end_time = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 23, 59, 59, "IST")
      when "RTGS", "rtgs"
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
      date = DateUtils.local_date
    else
      date = date.to_date
    end
    return date.to_date if within_timeframe? payment_mode, date
    if date <= Date.today
      date = DateUtils.local_date
    else
      date.change(hour: 8, min: 1, sec: 0)
    end
    return date.to_date if ["IMPS", "NEFT"].include?( payment_mode )
    case payment_mode.upcase
      when "RTGS"
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

  def self.add_business_days(date, no_of_days=1)
    date_count  = 0
    if date.blank?
      date = DateTime.now
    end
    business_date = date
    loop do
      business_date = business_date + 1.day
      if bank_holidays.exclude?(business_date.strftime("%d-%m-%Y")) && [0,6].exclude?(business_date.wday)
        date_count += 1
      end
      return business_date if date_count == no_of_days
    end
  end

  def self.subtract_business_days(date, no_of_days=1)
    date_count  = 0
    if date.blank?
      date = DateTime.now
    end
    business_date = date
    loop do
      business_date = business_date - 1.day
      if bank_holidays.exclude?(business_date.strftime("%d-%m-%Y")) && [0,6].exclude?(business_date.wday)
        date_count += 1
      end
      return business_date if date_count == no_of_days
    end
  end

end