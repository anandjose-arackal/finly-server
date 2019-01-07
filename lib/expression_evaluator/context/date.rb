class ExpressionEvaluator::Context::Date < ExpressionEvaluator::Context::Base

  def month(options={})
    if options&.dig(:args).blank?
      options = {args: '%b'}
    end
    date(options)
  end

  def day(options={})
    if options&.dig(:args).blank?
      options = {args: '%d'}
    end
    date(options)
  end

  def year(options={})
    if options&.dig(:args).blank?
      options = {args: '%Y'}
    end
    date(options)
  end

  def date(options = {})
    format = options&.dig(:args)
    if format.blank?
      format = '%d/%b/%y'
    end
    ExpressionEvaluator::Context::String.new(Date.today.strftime(format))
  end

end