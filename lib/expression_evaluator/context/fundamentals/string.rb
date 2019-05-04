class ExpressionEvaluator::Context::Fundamentals::String < ExpressionEvaluator::Context::Base

  def valid_data?
    data.class.name == ::String
  end

  def downcase(options = {})
    string_format(data.downcase)
  end

  def upcase(options = {})
    string_format(data.upcase)
  end

  def first(options={})
    size = options[:args]
    return nil if size.blank?

    string_format(data.first(size.to_i))
  end

  def last(options={})
    size = options[:args]
    return nil if size.blank?

    string_format(data.last(size.to_i))
  end

  def words_only(options={})
    string_format(data.gsub(/\W/,''))
  end

end