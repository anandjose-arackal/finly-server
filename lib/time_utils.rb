class TimeUtils

  def self.to_ist(datetime)
    return nil if datetime.blank?
    datetime = datetime.to_s unless datetime.is_a?(String)
    Time.parse(datetime).in_time_zone('Kolkata')
  end

end