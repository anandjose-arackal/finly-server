class ExpressionEvaluator::Context::Documents::PurchaseOrder < ExpressionEvaluator::Context::Base

  alias_method :purchase_order, :data

  def self.accept?(data=nil)
    data and data.class.name == ::PurchaseOrder.name
  end

  def cost_center(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_order.cost_center&.id)
    when :name
      return string_format(self.purchase_order.cost_center&.name)
    else
      nil
    end
  end

  def department(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_order.department&.id)
    when :name
      return string_format(self.purchase_order.department&.name)
    else
      nil
    end
  end

  def location(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_order.location&.id)
    when :name
      return string_format(self.purchase_order.location&.name)
    else
      nil
    end
  end

end