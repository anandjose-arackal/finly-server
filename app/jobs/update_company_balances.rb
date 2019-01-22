class UpdateCompanyBalances < ApplicationJob

  def perform
    Company.all.each do |company|
      # date = DateUtils.yesterday_local_date
      # Company::Balances::SetBalances.(company, {date: date})

      #### Because the corporate balance API from ItzCash needs to be shown in the statements
      Company::Transaction::Show.(company, {start_date: Date.today, end_date: Date.today})
      ####################################### END ###########################################
    end
  end

end