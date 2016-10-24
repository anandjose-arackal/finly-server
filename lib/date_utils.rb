class DateUtils

  def self.local_date
    Time.now.in_time_zone('Kolkata').to_date
  end

end