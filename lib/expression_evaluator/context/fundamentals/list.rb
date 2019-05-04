class ExpressionEvaluator::Context::Fundamentals::List < ExpressionEvaluator::Context::Base

  def valid_data?
    data.respond_to?(:each)
  end

  def map(options={})
    ExpressionEvaluator::Context::Fundamentals::List::Mapper.new(data)
  end

  def join(options={})
    delimiter = options[:args] || '/'
    string_format(data.join(delimiter))
  end

  class ExpressionEvaluator::Context::Fundamentals::List::Mapper < ExpressionEvaluator::Context::Fundamentals::List

    def send(method, options)
      result = []
      data.each do |item|
        result << item.send(method, options)
      end
      ExpressionEvaluator::Context::Fundamentals::List.new(result)
    end

  end

end