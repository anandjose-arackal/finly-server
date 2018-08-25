class Procurements::ProcureInwardInvoices::Base < Procurements::Base

  class Procurements::ProcureInwardInvoices::InwardInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end
end