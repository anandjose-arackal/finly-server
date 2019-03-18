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

    # General Filters from frontend
    has_scope :filter_policy_id
    has_scope :filter_department_id
    has_scope :filter_sub_department_id
    has_scope :filter_month
    has_scope :filter_year

    def init
      general_filter_params = {
        filter_policy_id: params[:filter_policy],
        filter_department_id: params[:filter_department],
        filter_sub_department_id: params[:filter_sub_department],
        filter_month: params[:filter_month],
        filter_year: params[:filter_year]
      }

      self.purchase_orders = params[:purchase_orders]
      self.purchase_orders = apply_scopes(self.purchase_orders, general_filter_params)
      self.counts = []

      if user.is_bank_payment_request_creditor?

        # policy_ids = Policy::Index.(user, params).policies
        
        creditor_data = {
          type: 'creditor',
          title: "Teams' Purchase Orders",
          data: [
            {
              title: "Total POs with Advances",
              count: apply_scopes(purchase_orders, {filter_all_advances: true})&.count,
              filters: []
            },
            {
              title: "Payable POs",
              count: apply_scopes(purchase_orders, {filter_payable_advances: true})&.count,
              filters: []
            }
          ]
        }

        self.counts.push(creditor_data)
      end
    end
  end
end