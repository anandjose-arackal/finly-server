class Invoicing::Invoice::GenerateInvoiceNumber < Invoicing::Invoice::Base

  attr_accessor :invoice_number_config, :invoice_number, :invoice

  class Invoicing::Invoice::GenerateInvoiceNumber::InvoiceNumberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice_number

    def init
      self.invoice_number = params[:invoice_number]
    end

  end

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
    iteration = 1
    loop do
      if self.invoice_number_config.prefix.present?
        self.invoice_number = self.invoice_number_config.prefix
      end
      if self.invoice_number_config.sequence_start.present?
        last_invoice = user.company.outward_invoices.invoice_number_generated_in_finly.valid.reorder(created_at: :desc).first
        if last_invoice.present? && last_invoice.created_at > self.invoice_number_config.updated_at
          numeric_section = last_invoice.invoice_number.gsub(/[^0-9a-z ]/i, '')
          new_numeral = numeric_section
          iteration.times do
            new_numeral = numeric_section.succ
          end
          self.invoice_number += new_numeral.to_s
        elsif (last_invoice.present? && last_invoice.created_at <= self.invoice_number_config.updated_at) || last_invoice.blank?
          numeric_section = self.invoice_number_config.sequence_start
          new_numeral = numeric_section
          iteration.times do
            new_numeral = numeric_section.succ
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