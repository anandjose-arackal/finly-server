class Company::Statement::Base < Company::Base

  attr_accessor :start_date, :end_date

  def init
    if params[:filter_date_from]
      self.start_date = DateTime.parse(params[:filter_date_from])
    else
      self.start_date = DateTime.parse("01-01-1990") # arbitrarily chosen as the lower bound date
    end
    if params[:filter_date_to]
      self.end_date = DateTime.parse(params[:filter_date_to] + " 23:59:59")
    else
      self.end_date = DateUtils.local_date_time
    end
  end

end