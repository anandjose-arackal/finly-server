class Procurements::Create < Procurements::Base
  attr_accessor :procurement

  def init
  end

  def process
    self.procurement = user.procurements.build({company_id: user.company.id})
    self.procurement.procurement_status_id = ProcurementStatus.id_for(:draft)
    unless self.procurement.save
      add_message :error, self.procurement.errors.full_messages
    end
  end
end