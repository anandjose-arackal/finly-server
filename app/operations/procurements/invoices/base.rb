class Procurements::Invoices::Base < BaseOperation
  attr_accessor :workflow_output


  class Procurements::Invoices::InwardInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end
end