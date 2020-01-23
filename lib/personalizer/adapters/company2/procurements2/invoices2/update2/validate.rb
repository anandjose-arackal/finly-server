class Personalizer::Adapters::Company2::Procurements2::Invoices2::Update2::Validate < Personalizer::Adapters::Base

  attr_accessor :inward_invoice, :invoice_params

  def init
    self.inward_invoice = op_instance.inward_invoice
    self.invoice_params = op_instance.inward_invoice_params
  end

  def validate
    if invoice_params[:due_date].blank?
      add_message :error, "Invoice due date is mandatory"
      return
    end
  end

end