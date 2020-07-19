class Admin::Masters::Macros::Contracts::Schedule < Reform::Form
  property :frequency, validates: {presence: true, inclusion: {in: MacroSchedule::FREQUENCY}}
  property :hour
  property :minute
  property :day_of_the_week
  property :day_of_the_month

  validate :minute_format
  validate :hour_format
  validate :day_of_the_week_format
  validate :day_of_the_month_format

  def minute_format
    if self.hour.blank?
      errors.add :hour, 'cannot be blank'
      return
    end

    valid_minutes = (0..11).to_a.map { |i| i * 5 }
    unless valid_minutes.include?(self.minute.to_i)
      errors.add :minute, 'is invalid'
    end
  end

  def hour_format
    required = %w(
        daily weekly monthly last_day_of_month
    ).include?(frequency.to_s)

    if required
      if self.hour.blank?
        errors.add :hour, 'cannot be blank'
        return
      end

      unless (1..24).to_a.include?(self.hour.to_i)
        errors.add :hour, 'is invalid'
      end
    else
      if self.hour.present?
        errors.add :hour, 'cannot be set'
      end
    end
  end

  def day_of_the_week_format
    required =%w(
        weekly
    ).include?(frequency.to_s)

    if required
      if self.day_of_the_week.blank?
        errors.add :day_of_the_week, 'cannot be blank'
        return
      end

      unless MacroSchedule::DAY_OF_THE_WEEK.values.include?(self.day_of_the_week.to_s)
        errors.add :day_of_the_week, 'is invalid'
      end
    else
      if self.day_of_the_week.present?
        errors.add :day_of_the_week, 'cannot be set'
      end
    end
  end

  def day_of_the_month_format
    required = %w(
        monthly
    ).include?(frequency)

    if required
      if self.day_of_the_month.blank?
        errors.add :day_of_the_month, 'cannot be blank'
        return
      end

      unless (1..30).to_a.include?(self.day_of_the_month.to_i)
        errors.add :day_of_the_month, 'is invalid'
      end
    else
      if self.day_of_the_month.present?
        errors.add :day_of_the_month, 'cannot be set'
      end
    end
  end
end