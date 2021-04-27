class BbpsBillerSync < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------ "

    Procurements::Bbps::Billers::Synchronize.()

    puts " ----------------------------- FINISHED #{self.name} ------------------------------ "
  end
end