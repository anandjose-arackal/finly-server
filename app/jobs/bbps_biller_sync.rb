class BbpsBillerSync

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------ "

    Procurements::Bbps::Billers::Synchronize.()

    puts " ----------------------------- FINISHED #{self.name} ------------------------------ "
  end
end