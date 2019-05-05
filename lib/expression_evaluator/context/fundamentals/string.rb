class ExpressionEvaluator::Context::Fundamentals::String < ExpressionEvaluator::Context::Base

  def self.accept?(data=nil)
    data and data.class.name == ::String.name
  end

  def downcase(options = {})
    data.downcase
  end

  def upcase(options = {})
    data.upcase
  end

  def first(options={})
    size = options[:args]
    return nil if size.blank?

    data.first(size.to_i)
  end

  def last(options={})
    size = options[:args]
    return nil if size.blank?

    data.last(size.to_i)
  end

  def words_only(options={})
    data.gsub(/\W/,'')
  end

end