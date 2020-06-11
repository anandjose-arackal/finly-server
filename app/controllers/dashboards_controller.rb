class DashboardsController < BaseControllers::WebBase

  # Fixme: Migration to new structure.
  def configs
    @result = Dashboard::VendorPayments::Configs.(current_user, params)
    respond
  end

  def show
    handler = nil
    case params[:route].to_s
    when 'awaiting_action'
      handler = Dashboard::P2P::PurchaseOrders
    when 'purchase_orders'
      handler = Dashboard::P2P::PurchaseOrders
    when 'purchase_requests'
      handler = Dashboard::P2P::PurchaseOrders
    when 'payment_tickets'
      handler = Dashboard::P2P::PurchaseOrders
    when 'invoices'
      handler = Dashboard::P2P::Invoices
    when 'po_advances'
      handler = Dashboard::P2P::PurchaseOrders
    when 'grns'
      handler = Dashboard::P2P::PurchaseOrders
    when 'vendors'
      handler = Dashboard::P2P::PurchaseOrders
    when 'payment_agreements'
      handler = Dashboard::P2P::PurchaseOrders
    when 'purchase_request_approved_items'
      handler = Dashboard::P2P::PurchaseOrders
    when 'agreement_invoices'
      handler = Dashboard::P2P::PurchaseOrders
    when 'utility_bill_masters'
      handler = Dashboard::P2P::PurchaseOrders
    when 'utility_bills'
      handler = Dashboard::P2P::PurchaseOrders
    else
      respond render: :failure
    end
    endpoint handler
  end

end
