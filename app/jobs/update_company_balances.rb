class UpdateCompanyBalances

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name}  at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    Company.all.each do |company|
      # date = DateUtils.yesterday_local_date
      # Company::Balances::SetBalances.(company, {date: date})

      #### Because the corporate balance API from ItzCash needs to be shown in the statements
      Company::Transaction::Show.(company, {start_date: Date.today, end_date: Date.today})
      ####################################### END ###########################################
    end

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end

end