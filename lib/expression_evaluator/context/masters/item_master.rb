class ExpressionEvaluator::Context::Masters::ItemMaster < ExpressionEvaluator::Context::Base

  alias_method :category, :data

  def self.accept?(data=nil)
    data and data.class.name == Item.name
  end

  def category(options={})
    data.category
  end

end