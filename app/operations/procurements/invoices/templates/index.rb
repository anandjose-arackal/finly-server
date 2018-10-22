class Procurements::Invoices::Templates::Index < Procurements::Invoices::Templates::Base
  attr_accessor :invoice_templates

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.invoice_templates = user.invoice_templates
  end

  def success
    params[:invoice_templates] = self.invoice_templates
    Procurements::Invoices::Templates::Index::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Templates::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice_templates

    def init
      self.invoice_templates = params[:invoice_templates]
    end

  end

end