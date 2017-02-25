class UpdateCompanyBalances < ActiveJob::Base

  def perform
    Company.all.each do |company|
      date = DateUtils.yesterday_local_date
      Company::Balances::UpdateBalances.(company, {date: date})
    end
  end

end
