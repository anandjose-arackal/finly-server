class Invoicing::Invoice::Show < Invoicing::Invoice::Base

  attr_accessor :invoice

  class Invoicing::Invoice::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:invoice]
    end

  end

  def init
    id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
  end

  def process

  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Show::InvoicePresenter.new(user, params, messages)
  end
end