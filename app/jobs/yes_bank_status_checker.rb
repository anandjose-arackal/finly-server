class YesBankStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    handle = self.object_id
    YesBankStatusCheckerBackground.perform_async(handle, nil)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end