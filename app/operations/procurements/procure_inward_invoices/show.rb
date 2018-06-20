class Procurements::ProcureInwardInvoices::Show < Procurements::ProcureInwardInvoices::Base
  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id]
    self.invoice = Invoice.find_by id: invoice_id
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
  end

  class Procurements::ProcureInwardInvoices::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice

    def init
      self.invoice = params[:invoice]
    end
  end


end