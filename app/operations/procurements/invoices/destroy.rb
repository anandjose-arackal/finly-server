class Procurements::Invoices::Destroy < Procurements::Invoices::Base
  # todo
  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice

  def init
    id = params[:id] || params[:purchase_order_id]
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

end