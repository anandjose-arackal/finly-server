class ScheduledBankTransferProcess < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    handle = self.object_id
    ScheduledBankTransferProcessBackground.perform_async(handle, nil)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end