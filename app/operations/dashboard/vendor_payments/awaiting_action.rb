class Dashboard::VendorPayments::AwaitingAction < Dashboard::VendorPayments::Base
  attr_accessor :items

  def init
    self.items = [
      {purchase_orders: PurchaseOrder.awaiting_action_items(user).count},
      {payment_tickets: BankPaymentRequest.awaiting_action_items(user).count},
      {vendors: YesBankVendor.awaiting_action_items(user).count},
      {po_invoices: Invoice.awaiting_action_items(user).count},
      {non_po_invoices: Invoice.awaiting_action_items(user).count},
      # {purchase_requests: PurchaseRequest.awaiting_action_items(user)} #todo
    ]
  end

  def success
    params[:items] = self.items
    Dashboard::VendorPayments::AwaitingAction::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::AwaitingAction::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end
end