class ExpressionEvaluator::Context::Documents::GoodsReceiptNote < ExpressionEvaluator::Context::Base

  alias_method :grn, :data

  def self.accept?(data=nil)
    data and data.class.name == InwardDocument.name
  end

  def cost_center(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_order&.cost_center&.id)
    when :name
      return string_format(self.purchase_order&.cost_center&.name)
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

  protected
  def purchase_order
    self.grn&.procurement&.purchase_order
  end

end