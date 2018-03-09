class Invoicing::Invoice::Show < Invoicing::Invoice::Base

  attr_accessor :invoice, :invoice_number, :payment_terms

  class Invoicing::Invoice::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice, :invoice_number, :payment_terms

    def init
      self.invoice = params[:invoice]
      self.invoice_number = params[:invoice_number]
      self.payment_terms = params[:payment_terms]
    end

    def navbar_actions
      actions = []
      if invoice.incomplete?
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_path(self.invoice),
            name: "Delete Invoice",
            method: "delete",
            id: "delete_invoice",
            btn_class: "danger"
        }
      end
      if self.invoice.saved?
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_cancel_path(self.invoice),
            name: "Cancel Invoice",
            method: "patch",
            id: "cancel_invoice",
            btn_class: "danger"
        }
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_mark_as_closed_path(self.invoice),
            name: "Mark as Closed",
            method: "patch",
            id: "mark_as_closed",
            btn_class: "info"
        }
      end
      unless self.invoice.incomplete?
        actions << {
            url: Rails.application.routes.url_helpers.invoicing_outward_invoice_download_path(self.invoice),
            name: "Download Invoice",
            method: "get",
            id: "download_invoice",
            btn_class: "info"
        }
        unless self.invoice.cancelled? || self.invoice.closed?
          actions << {
              url: Rails.application.routes.url_helpers.invoicing_outward_invoice_send_to_customer_path(self.invoice),
              name: "Send to Customer",
              method: "patch",
              id: "send_invoice",
              btn_class: "info"
          }
        end
      end
      actions
    end
  end

  def init
    id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.include_soft_deleted.find_by(id: id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end
  end

  def process
    if self.invoice.invoice_number.blank?
      op = Invoicing::Invoice::GenerateInvoiceNumber.(user, {invoice: self.invoice})
      self.invoice_number = op.invoice_number
    end
    self.payment_terms = user.company.payment_terms
  end

  def success
    params[:invoice] = self.invoice
    params[:invoice_number] = self.invoice_number
    params[:payment_terms] = self.payment_terms
    Invoicing::Invoice::Show::InvoicePresenter.new(user, params, messages)
  end
end