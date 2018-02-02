class Invoicing::Invoice::Show < Invoicing::Invoice::Base

  attr_accessor :invoice

  class Invoicing::Invoice::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:invoice]
    end

    def navbar_actions
      actions = []
      if invoice.incomplete?
        # adding the save action
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_save_path(self.invoice),
            name: "Create Invoice",
            method: "patch",
            id: "create_invoice"
        }
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_path(self.invoice),
            name: "Delete Invoice",
            method: "delete",
            id: "delete_invoice"
        }
      end
      if self.invoice.saved? || self.invoice.sent_to_customer?
        actions << {
            url: Rails.application.routes.url_helpers.(self.invoice),
            name: "Cancel Invoice",
            method: "patch",
            id: "cancel_invoice"
        }
      end
      actions
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