class Procurements::Invoices::Templates::Create < Procurements::Invoices::Templates::Base
  attr_accessor :invoice, :template

  def pre_validate
    user_present? and params_present?
    return if has_errors?
  end

  def init
    result = Procurements::Invoices::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.invoice = result.invoice
    # self.invoice = Invoice.find(params[:inward_invoice_id])
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
      return
    end
  end

  def process
    result = ::Template::Create.(user, resource: self.invoice, template_name: params[:template_name])
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.template
  end

  def post_process
    add_message :success, 'Template saved'
  end

  def success
    params[:template] = self.template
    Procurements::Invoices::Templates::Create::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Templates::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :template

    def init
      self.template = params[:template]
    end

  end

end