class Procurements::InwardInvoices::Base < Procurements::Base


  class Procurements::InwardInvoices::InwardInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end
end