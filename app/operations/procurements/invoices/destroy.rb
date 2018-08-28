class Procurements::Invoices::Destroy < Procurements::Invoices::Base
  # todo
  attr_accessor :procurement, :invoice, :invoice_params, :invoice

  def init
    id = params[:id] || params[:invoice_id]
    self.procurement = user.company.procurements.find_by(id: id)
    self.invoice = self.procurement.invoice
    self.invoice_params = set_invoice_parameters
  end

  def validate
    if self.procurement.blank?
      add_message :success, "Procurement not found"
      return
    end

    if self.invoice.blank?
      add_message :error, "Invoice not present"
      return
    end

    if self.invoice_params.blank?
      add_message :error, "Procurement or invoice not present"
    end
  end

end