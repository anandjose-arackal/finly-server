class ExpressionEvaluator::Context::Fundamentals::Date < ExpressionEvaluator::Context::Base

  def self.accept?(data=nil)
    true
  end

  def month(options={})
    if options&.dig(:args).blank?
      options = {args: '%b'}
    end
    current_date(options)
  end

  def day(options={})
    if options&.dig(:args).blank?
      options = {args: '%d'}
    end
    current_date(options)
  end

  def year(options={})
    if options&.dig(:args).blank?
      options = {args: '%Y'}
    end
    current_date(options)
  end

  def current_date(options = {})
    format = options&.dig(:args)
    if format.blank?
      format = '%d/%b/%y'
    end
    Date.today.strftime(format)
  end

  def fiscal_year_start(options={})
    format = options&.dig(:args)
    if format.blank?
      format = '%y'
    end

    fy_start_month = 4
    if Date.today.month >= fy_start_month
      Date.today.strftime(format)
    else
      ((Date.today) - 1.year).strftime(format)
    end
  end

  def fiscal_year_end(options={})
    format = options&.dig(:args)
    if format.blank?
      format = '%y'
    end

    fy_start_month = 4
    if Date.today.month < fy_start_month
      Date.today.strftime(format)
    else
      ((Date.today) + 1.year).strftime(format)
    end
  end

end