class DateUtils

  def self.local_date
    Time.now.in_time_zone('Kolkata').to_date
  end

  def self.validate_date_format?(date_s)
    y, m, d = date_s.split '-'
    unless Date.valid_date? y.to_i, m.to_i, d.to_i
      return false
    end
    true
  end

end