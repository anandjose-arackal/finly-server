class Invoicing::Invoice::GenerateInvoiceNumber < Invoicing::Invoice::Base

  attr_accessor :invoice_number_config, :invoice_number, :invoice

  def init
    self.invoice_number_config = user.company.invoice_number_config
    self.invoice = params[:invoice]
  end

  def validate
    if self.invoice_number_config.blank?
      add_message :error, "Invoice number generation is not enabled for your company"
      return
    end
  end

  def process
    self.invoice_number = ""
    loop do
      if self.invoice_number_config.prefix.present?
        self.invoice_number = self.invoice_number_config.prefix
      end
      if self.invoice_number_config.sequence_start.present?
        last_invoice = user.company.outward_invoices.valid.reorder(created_at: :desc).first
        if last_invoice.present? && last_invoice.created_at > self.invoice_number_config.updated_at

        end
        if last_invoice&.created_at <= self.invoice_number_config.updated_at

        end
      end
    end
  end

end