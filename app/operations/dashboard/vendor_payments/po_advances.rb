class Dashboard::VendorPayments::POAdvances < Dashboard::VendorPayments::Base
  attr_accessor :purchase_orders

  def init
    params[:filter_po_advances]
    self.purchase_orders = Procurements::PurchaseOrders::Index.(user, params).purchase_orders
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Dashboard::VendorPayments::POAdvances::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::POAdvances::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders, :counts

    has_scope :filter_all_advances
    has_scope :filter_payable_advances

    def init
      self.purchase_orders = params[:purchase_orders]
      self.counts = []

      if user.is_bank_payment_request_creditor?

        # policy_ids = Policy::Index.(user, params).policies
        
        creditor_data = {
          type: 'creditor',
          title: "Teams' Purchase Orders",
          data: [
            {
              title: "Total POs with Advances",
              count: apply_scopes(purchase_orders, {filter_all_advances: true})&.count
            },
            {
              title: "Payable POs",
              count: apply_scopes(purchase_orders, {filter_payable_advances: true})&.count
            }
          ]
        }

        self.counts.push(creditor_data)
      end
    end
  end
end