class PeriodUtils

  def self.start_date_for(date, period_id)
    return nil if period_id.blank? or date.blank?
    return nil unless date.is_a?(Date)
    case period_id
      when Period.id_for(:day)
        return date
      when Period.id_for(:week)
        return date.beginning_of_week
      when Period.id_for(:month)
        return date.beginning_of_month
      when Period.id_for(:yearly)
        return date.beginning_of_year
    end
  end

  def self.end_date_for(date, period_id)
    return nil if period_id.blank? or date.blank?
    return nil unless date.is_a?(Date)
    case period_id
      when Period.id_for(:day)
        return date
      when Period.id_for(:week)
        return date.end_of_week
      when Period.id_for(:month)
        return date.end_of_month
      when Period.id_for(:yearly)
        return date.end_of_year
    end
  end

end