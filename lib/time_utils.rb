class TimeUtils

  def self.to_ist(datetime)
    return nil if datetime.blank?
    datetime = datetime.to_s unless datetime.is_a?(String)
    Time.parse(datetime).in_time_zone('Kolkata')
  end

  def self.humanize_seconds(secs)
    return nil unless secs.present?

    [[60, :secs], [60, :mins], [24, :hours], [Float::INFINITY, :days]].map {|count, name|
      if secs > 0
        secs, n = secs.divmod(count)

        "#{n.to_i} #{name}" unless n.to_i == 0
      end
    }.compact.reverse.join(' ')
  end

end