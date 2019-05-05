class ExpressionEvaluator::Context::Masters::Category < ExpressionEvaluator::Context::Base

  alias_method :category, :data

  def self.accept?(data=nil)
    data and data.class.name == ::Category.name
  end

  def name(options={})
    data.name
  end

  def ancestors(options={})
    data.ancestors
  end

end