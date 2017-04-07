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
    d, m, y = date_s.split '-'
    unless Date.valid_date? y.to_i, m.to_i, d.to_i
      return false
    end
    true
  end

  def self.datetime_in_ist(datetime)
    return nil if datetime.blank?
    datetime += " +5:30" unless datetime.include?("+5:30")
    datetime
  end

end
