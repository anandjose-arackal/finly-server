class Procurements::Invoices::Base < Procurements::Base

  class Procurements::Invoices::InwardInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end
end