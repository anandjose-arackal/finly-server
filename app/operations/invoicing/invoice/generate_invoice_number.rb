class Invoicing::Invoice::GenerateInvoiceNumber < Invoicing::Invoice::Base

  attr_accessor :invoice_number_config, :invoice_number, :invoice, :purpose_id, :invoice_number_config_type_id, :invoice_type

  class Invoicing::Invoice::GenerateInvoiceNumber::InvoiceNumberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice_number

    def init
      self.invoice_number = params[:invoice_number]
    end

  end

  def init
    self.invoice = params[:invoice]
    if self.invoice.is_a?(OutwardInvoice)
      self.purpose_id = Purpose.id_for(:collect)
      self.invoice_type = invoice.outward_invoice_type.name
      self.invoice_number_config_type_id = InvoiceNumberConfigType.id_for(self.invoice_type)
    elsif self.invoice.is_a?(Invoice)
      self.purpose_id = Purpose.id_for(:vendor_payments)
      #todo do the same for inward invoice
    else
      add_message :error, "Invalid purpose passed"
      return
    end

    self.invoice_number_config = user.company.invoice_number_configs.with_purpose_id(purpose_id).with_config_type_id(invoice_number_config_type_id).first
  end

  def validate
    if self.invoice_number_config.blank?
      add_message :error, "Invoice number generation is not enabled for your company"
      return
    end
  end

  def process
    iteration = 1
    loop do
      self.invoice_number = ""
      if self.invoice_number_config.prefix.present?
        self.invoice_number = self.invoice_number_config.prefix
      end
      if self.invoice_number_config.sequence_start.present?
        last_invoice = user.company.outward_invoices.with_type(invoice_type).invoice_number_generated_in_finly.valid.reorder(created_at: :desc).first
        if last_invoice.present? && last_invoice.created_at > self.invoice_number_config.updated_at
          prefix = last_invoice.prefix || self.invoice_number_config.prefix
          numeric_section = last_invoice.invoice_number.gsub(prefix, '')
          new_numeral = numeric_section
          iteration.times do
            new_numeral = new_numeral.succ
          end
          self.invoice_number += new_numeral.to_s
        elsif (last_invoice.present? && last_invoice.created_at <= self.invoice_number_config.updated_at) || last_invoice.blank?
          numeric_section = self.invoice_number_config.sequence_start
          new_numeral = numeric_section
          iteration.times do
            new_numeral = new_numeral.succ
          end
          self.invoice_number += new_numeral.to_s
        end
      end
      if user.company.outward_invoices.find_by(invoice_number: self.invoice_number)
        iteration += 1
      else
        break
      end
    end
  end

  def success
    params[:invoice_number] = self.invoice_number
    Invoicing::Invoice::GenerateInvoiceNumber::InvoiceNumberPresenter.new(user, params, messages)
  end

end