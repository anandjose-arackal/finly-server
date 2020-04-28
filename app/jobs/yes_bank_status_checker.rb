class YesBankStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    handle = self.object_id
    YesBankBalanceProvider.perform_async(handle, self.company.id)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end