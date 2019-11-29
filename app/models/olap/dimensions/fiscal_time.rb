class Olap::Dimensions::FiscalTime < OlapRecord

  def self.for_date(date)
    params = date_properties(date)
    self.find_or_initialize_by params
  end

  def self.for_datetime(datetime)
    params = date_properties(datetime).merge(
        {
            datetime: datetime
        }
    )
    self.find_or_initialize_by params
  end

  protected

  def self.date_properties(date)
    {
        date: date.to_date,
        week: date.cweek,
        day_of_week: date.wday,
        day_of_month: date.day,
        month: date.month,
        quarter: date.financial_quarter,
        half: date.financial_half,
        year: date.strftime("%Y"),
        fiscal_year: "#{date.beginning_of_financial_year.strftime("%Y")}-#{date.end_of_financial_year.strftime("%Y")}"
    }
  end

end
