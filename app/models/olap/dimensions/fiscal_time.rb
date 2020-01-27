# == Schema Information
#
# Table name: olap_dimensions_fiscal_times
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  datetime             :datetime
#  date                 :date
#  day_of_week          :string(255)
#  day_of_month         :integer
#  week                 :integer
#  month                :integer
#  quarter              :string(255)
#  half                 :string(255)
#  year                 :integer
#  fiscal_year          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

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
