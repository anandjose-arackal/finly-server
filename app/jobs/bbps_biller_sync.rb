class BbpsBillerSync < ApplicationJob

  def perform
    Procurements::Bbps::Billers::Synchronize.()
  end
end