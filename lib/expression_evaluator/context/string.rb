class ExpressionEvaluator::Context::String < ExpressionEvaluator::Context::Base

  def downcase(options={})
    if data.is_a?(String)
      return ExpressionEvaluator::Context::String.new(data.downcase)
    end
    nil
  end

  def upcase(options={})
    if data.is_a?(String)
      return ExpressionEvaluator::Context::String.new(data.upcase)
    end
    nil
  end

end