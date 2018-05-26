class Procurements::InwardInvoices::CreateFromPO < Procurements::InwardInvoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params

  def init
    id = params[:id] || params[:procurement_id]
    self.procurement = user.company.procurements.find_by(id: id)
    self.purchase_order = self.procurement.purchase_order
    self.invoice_params = set_invoice_parameters
  end

  def validate
    if self.procurement.blank?
      add_message :success, "Procurement not found"
      return
    end

    if self.purchase_order.blank?
      add_message :error, "Purchase order not present"
      return
    end

    if self.invoice_params.blank?
      add_message :error, "Procurement or purchase order not present"
    end
  end

  def process

  end

  private

  def set_invoice_parameters
    if self.procurement.blank? || self.purchase_order.blank?
      return nil
    end
    invoice_params = {

    }
  end

end