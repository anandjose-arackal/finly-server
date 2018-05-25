class Procurements::Create < Procurements::Base
  attr_accessor :procurement

  def init

  end

  def validate
    if params[:document_type].blank?
      add_message :error, 'Please provide document type to create procurement'
    end
  end

  def process
    self.procurement = user.procurements.build({company_id: user.company.id})

    self.procurement.procurement_status_id = ProcurementStatus.id_for(:draft)

    unless self.procurement.save
      add_message :error, self.procurement.errors.full_messages
      return
    end

    params[:procurement_id] = self.procurement.id
    case params[:document_type]
      when 'purchase_order'
        op = Procurements::PurchaseOrders::Create.(user, params)
      else
        add_message :error, 'Invalid document type provided'
        return

    end
    if op.success?
      add_message :success, 'Successfully created new procurement'
    end


  end
end