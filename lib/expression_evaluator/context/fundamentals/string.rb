class ExpressionEvaluator::Context::Fundamentals::String < ExpressionEvaluator::Context::Base

  def valid_data?
    data.is_a?(String)
  end

  def downcase(options = {})
    ExpressionEvaluator::Context::String.new(data.downcase)
  end

  def upcase(options = {})
    ExpressionEvaluator::Context::String.new(data.upcase)
  end

  def first(options={})
    size = options[:args]
    return nil if size.blank?

    ExpressionEvaluator::Context::String.new(data.first(size.to_i))
  end

  def last(options={})
    size = options[:args]
    return nil if size.blank?

    ExpressionEvaluator::Context::String.new(data.last(size.to_i))
  end

end