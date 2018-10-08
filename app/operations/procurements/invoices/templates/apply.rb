class Procurements::Invoices::Templates::Apply < Procurements::Invoices::Templates::Base
  attr_accessor :template, :invoice, :updated_invoice

  def init
    invoice_result = Procure::Invoices::Show.(user, params)
    unless invoice_result.success?
      add_message :error, invoice_result.messages[:error]
      return
    end
    self.invoice = invoice_result.invoice
    template_result = Procurements::Invoices::Templates::Show.(user, params)
    unless template_result.success?
      add_message :error, template_result.messages[:error]
      return
    end
    self.template = template_result.template
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Purchase Order not found'
      return
    end
    unless self.template.present?
      add_message :error, 'Template not found'
      return
    end
  end

  def process
    result = Template::Apply.(user, template: self.template, resource: self.resource)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.invoice = result.invoice
  end

  def success
    params[:invoice] = self.invoice
    params[:template] = self.template
  end

  class Procurements::Invoices::Templates::Apply::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice, :template

    def init
      self.invoice = params[:invoice]
      self.template = params[:template]
    end

  end

end