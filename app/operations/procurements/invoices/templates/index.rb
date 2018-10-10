class Procurements::Invoices::Templates::Index < Procurements::Invoices::Templates::Base
  attr_accessor :po_templates

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.po_templates = user.invoice_templates
  end

  def success
    params[:po_templates] = self.po_templates
    Procurements::Invoices::Templates::Index::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Templates::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :po_templates

    def init
      self.po_templates = params[:po_templates]
    end

  end

end