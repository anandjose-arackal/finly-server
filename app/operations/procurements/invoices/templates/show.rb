class Procurements::Invoices::Templates::Show < Procurements::Invoices::Templates::Base
  attr_accessor :invoice

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:id].blank? and params[:invoice_template_id].blank? and params[:template_id].blank?
      add_message :error, 'Template not found'
      return
    end
  end

  def init
    result = Procurements::Invoices::Templates::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    id = params[:invoice_template_id] || params[:template_id] || params[:id]
    self.invoice = result.invoices.find_by(id: id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, 'Template not found'
      return
    end
  end

  def success
    params[:invoice] = self.invoice
    Procurements::Invoices::Templates::Show::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Templates::Show::SuccessPresenter < BaseOperation::BasePresenter
    attr_accessor :invoice, :template

    def init
      self.invoice = params[:invoice]
      self.template = params[:invoice]
    end

  end

end