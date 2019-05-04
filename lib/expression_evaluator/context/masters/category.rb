class ExpressionEvaluator::Context::Masters::Category < ExpressionEvaluator::Context::Base

  alias_method :category, :data

  def self.accept?(data=nil)
    data and data.class.name == ::Category.name
  end

  def name(options={})
    string_format(data.name)
  end

  def ancestors(options={})
    list_format(data.ancestors.map {|item| ExpressionEvaluator::Context::Masters::Category.new(item) })
  end

end