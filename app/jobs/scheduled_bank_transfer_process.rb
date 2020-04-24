class ScheduledBankTransferProcess

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    handle = self.object_id
    ScheduledBankTransferProcessBackground.perform_async(handle, nil)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end