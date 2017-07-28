class DateUtils

  def self.local_date
    Time.now.in_time_zone('Kolkata').to_date
  end

  def self.local_date_time
    Time.now.in_time_zone('Kolkata')
  end

  def self.yesterday_local_date
    Date.yesterday
  end

  def self.validate_date_format?(date_s)
    begin
      Date.parse date_s
    rescue ArgumentError
      return false
    end
    true
  end

  def self.datetime_in_ist(datetime)
    return datetime if datetime.blank?
    datetime += " +5:30" unless datetime.include?("+5:30")
    datetime
  end

  def self.parse_datetime(date_s)
    begin
      return DateTime.parse date_s
    rescue ArgumentError
      return nil
    end
  end

  def self.parse_date(date_s)
    begin
      return Date.parse date_s
    rescue ArgumentError
      return nil
    end
  end

  def self.datetime_formatted(datetime)
    return datetime if datetime.blank?
    if datetime.is_a?(String)
      datetime = parse_datetime datetime
    end
    return datetime if datetime.blank?
    return datetime unless datetime.is_a?(Date) or datetime.is_a?(DateTime) or datetime.is_a?(ActiveSupport::TimeWithZone)
    datetime.strftime('%I:%M%P, %d %b %Y')
  end

  def self.date_formatted(date)
    return date if date.blank?
    if date.is_a?(String)
      date = parse_date date
    end
    return date if date.blank?
    return date unless date.is_a?(Date) or date.is_a?(DateTime) or date.is_a?(ActiveSupport::TimeWithZone)
    date.strftime('%d %b %Y')
  end

end
