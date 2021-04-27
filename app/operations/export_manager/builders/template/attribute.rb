class ExportManager::Builders::Template::Attribute
  attr_accessor :name, :template, :column_name, :toggle, :active

  def initialize(name:, template:, column_name: nil, toggle: nil, active: true)
    self.name = name
    self.template = template
    self.column_name = column_name || name.to_s.humanize
    self.toggle = toggle
    self.active = active
  end

  def feature_enabled?(company)
    user = company.users.first
    return true unless user.present?
    return true if toggle.blank?

    toggle = self.toggle
    toggle = {if: self.toggle} if self.toggle.is_a?(Array)

    if toggle[:if].present?
      klass, action = toggle[:if]
      return true if klass.new(user).send(action)
    elsif toggle[:unless].present?
      klass, action = toggle[:unless]
      return true unless klass.new(user).send(action)
    else
      raise "Invalid toggle #{self.toggle}"
    end

    false
  end

  def build
    {
        label: column_name,
        value: template
    }
  end

end