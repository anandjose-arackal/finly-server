class ExpressionEvaluator::Context::Fundamentals::List < ExpressionEvaluator::Context::Base

  def self.accept?(data=nil)
    data and data.respond_to?(:each)
  end

  def map(options = {})
    list = []
    data.each do |item|
      if item.class <= ExpressionEvaluator::Context::Base
        list << item
      else
        list << ExpressionEvaluator::Provider.for_data(item)
      end
    end
    ExpressionEvaluator::Context::Fundamentals::List::Mapper.new(list)
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