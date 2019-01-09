class Procurements::Invoices::Destroy < Procurements::Invoices::Base
  # todo
  attr_accessor :procurement, :invoice, :invoice_params, :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    # self.procurement = user.company.procurements.find_by(id: invoice_id)
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
    self.procurement = invoice.procurement
    # self.invoice_params = set_invoice_parameters
  end

  def validate
    if self.procurement.blank?
      add_message :success, "Procurement not found"
      return
    end

    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end
  end

  def process
    if procurement.procurement_type == 'invoice'
      if self.procurement.invoices.count == 1
        if self.procurement.destroy
          add_message :success, "Successfully Deleted Procurement"
        end
      else
        if self.invoice.destroy
          add_message :success, 'Successfully Deleted Invoice'
        end
      end
    else
      if self.invoice.destroy
        add_message :success, 'Successfully Deleted Invoice'
      end
    end
  end
end