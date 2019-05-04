class ExpressionEvaluator::Context::Documents::PurchaseRequest < ExpressionEvaluator::Context::Base

  alias_method :purchase_request, :data

  def self.accept?(data=nil)
    data and data.class.name == ::PurchaseRequest.name
  end

  def cost_center(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_request.cost_center&.id)
    when :name
      return string_format(self.purchase_request.cost_center&.name)
    else
      nil
    end
  end

  def department(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_request.department&.id)
    when :name
      return string_format(self.purchase_request.department&.name)
    else
      nil
    end
  end

  def location(options={})
    type = options&.dig(:args)&.to_sym || :name
    case type
    when :id
      return integer_format(self.purchase_request.location&.id)
    when :name
      return string_format(self.purchase_request.location&.name)
    else
      nil
    end
  end

end