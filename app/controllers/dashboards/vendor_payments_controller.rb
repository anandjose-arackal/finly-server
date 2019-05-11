class Dashboards::VendorPaymentsController < BaseControllers::WebBase

  def configs
    @result = Dashboard::VendorPayments::Configs.(current_user, params)
    respond
  end

  def awaiting_action
    @result = Dashboard::VendorPayments::AwaitingAction.(current_user, params)
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

  def po_advances
    @result = Dashboard::VendorPayments::POAdvances.(current_user, params)
    respond
  end

  def vendors
    @result = Dashboard::VendorPayments::Vendors.(current_user, params)
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

  def purchase_requests
    # to be built
    # now built
    @result = Dashboard::VendorPayments::PurchaseRequests.(current_user, params)
    respond
  end

  def payment_tickets
    @result = Dashboard::VendorPayments::PaymentTickets.(current_user, params)
    respond
  end

  def grns
    @result = Dashboard::VendorPayments::Grns.(current_user, params)
    respond
  end
end