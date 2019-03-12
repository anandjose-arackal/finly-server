class Dashboards::VendorPaymentsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def configs
    @result = Dashboard::VendorPayments::Configs.(current_user, params)
    respond
  end

  def budgets
    @result = Dashboard::VendorPayments::PurchaseOrders.(current_user, params)
    respond
  end

  def purchase_orders
    @result = Dashboard::VendorPayments::PurchaseOrders.(current_user, params)
    respond
  end

  def po_invoices
    params[:filter_inward_invoice_type] = 'tax_invoice'
    @result = Dashboard::VendorPayments::Invoices.(current_user, params)
    respond
  end

  def non_po_invoices
    params[:filter_inward_invoice_type] = 'non_po_invoice'
    @result = Dashboard::VendorPayments::Invoices.(current_user, params)
    respond
  end

  def purchase_requisitions
    # to be built
  end

  def payment_tickets
    @result = Dashboard::VendorPayments::PaymentTickets.(current_user, params)
    respond
  end
end