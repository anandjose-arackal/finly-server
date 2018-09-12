class Procurements::Create < Procurements::Base
  attr_accessor :procurement, :procurement_params

  def init
    self.procurement_params = procurement_parameters
  end

  def validate
    if params[:document_type].blank?
      add_message :error, 'Please provide document type to create procurement'
    end
  end

  def process
    self.procurement = user.procurements.build(procurement_params)
    self.procurement.company = user.company

    self.procurement.procurement_status_id = ProcurementStatus.id_for(:draft)

    unless self.procurement.save
      add_message :error, self.procurement.errors.full_messages
      return
    end

    params[:procurement_id] = self.procurement.id
    case params[:document_type]
      when 'purchase_order'
        op = Procurements::PurchaseOrders::Create.(user, params)
      when 'tax_invoice', 'proforma_invoice'
        add_message :error, 'Invalid document type provided'
        op = Procurements::Invoices::Create.(user, params)
        # do nothing!
        # tax invoice / proforma invoice will be created
      else
        add_message :error, 'Invalid document type provided'
        return

    end
    if op.success?
      add_message :success, 'Successfully created new procurement'
    else
      add_message :error, op.messages[:error]
    end
  end

  private

  def procurement_parameters
    params.require(:procurement).permit(:name, :note, :vendor_id)
  end
end