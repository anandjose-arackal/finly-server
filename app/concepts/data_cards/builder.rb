class DataCards::Builder
  attr_accessor :title, :icon, :subtitle, :type
  attr_reader :status

  INDICATOR = {
    success: ['approved', 'closed'],
    warning: ['in_progress', 'awaiting_approval'],
    failure: ['rejected'],
    info: []
  }

  # def title=(title:, icon: nil, subtitle: nil)
  #   @header = {title: title, icon: icon, subtitle: subtitle}
  # end

  def status
    @status ||= {}
  end

  def status=(value, indicator: nil)
    indicator ||= indicator_for(value)
    @status = { value: value, indicator: indicator }
  end

  def details
    @details ||= []
  end

  def details=(value)
    @details = value unless value.nil?
  end

  def add_detail(icon: nil, label:, value:)
    details << { icon: icon, label: label, value: value }
  end

  def as_json(options = {})
    {
      title: title,
      subtitle: subtitle,
      type: type,
      icon: icon,
      status: status,
      details: details,
    }
  end

  protected

  def indicator_for(value)
    INDICATOR.each do |key, value|
      return key if value.include?(value.to_s)
    end

    # Return 'warning' if indicatory is not found
    'warning'
  end
end
