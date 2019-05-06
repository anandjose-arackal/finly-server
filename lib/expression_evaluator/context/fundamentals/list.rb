class ExpressionEvaluator::Context::Fundamentals::List < ExpressionEvaluator::Context::Base

  def valid_data?
    data.respond_to?(:each)
  end

  def map(options = {})
    ExpressionEvaluator::Context::Fundamentals::List::Mapper.new(data)
  end

  def join(options = {})
    delimiter = options[:args] || '/'
    data.join(delimiter)
  end

  class ExpressionEvaluator::Context::Fundamentals::List::Mapper < ExpressionEvaluator::Context::Fundamentals::List

    def send(method, options)
      data.map {|item| item.send(method, options)}
    end

  end

end