class YesBankStatusChecker < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    handle = self.object_id
    YesBankStatusCheckerBackground.perform_async(handle, nil)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end