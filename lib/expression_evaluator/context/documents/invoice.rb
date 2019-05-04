class ExpressionEvaluator::Context::Documents::Invoice < ExpressionEvaluator::Context::Base

  alias_method :invoice, :data

  def self.accept?(data=nil)
    data and data.class.name == ::Invoice.name
  end

  def cost_center(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.invoice.cost_center&.id)
    when :name
      return string_format(self.invoice.cost_center&.name)
    else
      nil
    end
  end

  def department(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.invoice.department&.id)
    when :name
      return string_format(self.invoice.department&.name)
    else
      nil
    end
  end

  def location(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.invoice.location&.id)
    when :name
      return string_format(self.invoice.location&.name)
    else
      nil
    end
  end

end