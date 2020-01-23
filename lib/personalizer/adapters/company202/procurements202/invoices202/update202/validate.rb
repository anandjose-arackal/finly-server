class Personalizer::Adapters::Company202::Procurements202::Invoices202::Update202::Validate < Personalizer::Adapters::Base

  attr_accessor :inward_invoice, :invoice_params

  def init
    self.inward_invoice = op_instance.inward_invoice
    self.invoice_params = op_instance.inward_invoice_params
  end

  def validate
    if invoice_params[:date].blank?
      add_message :error, "Invoice date is mandatory"
      return
    end
  end

end