class Dashboard::VendorPayments::PurchaseOrders < Dashboard::VendorPayments::Base
  attr_accessor :purchase_orders

  def init
    self.purchase_orders = Procurements::PurchaseOrders::Index.(user, params).purchase_orders
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Dashboard::VendorPayments::PurchaseOrders::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PurchaseOrders::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders, :counts

    has_scope :filter_status_id
    has_scope :filter_user_id

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

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: purchase_orders.count,
              filters: []
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count,
              filters: [
                {filter_po_status: PurchaseOrderStatus.id_for(:processing)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count,
              filters: [
                {filter_po_status: PurchaseOrderStatus.id_for(:approved)}
              ]
            },
            {
              title: "Sent to Vendor",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor)})&.count,
              filters: [
                {filter_po_status: PurchaseOrderStatus.id_for(:sent_to_vendor)}
              ]
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.is_purchase_order_initiator? || user.vp_admin_or_auditor?
        personal_data = {
          type: 'personal',
          data: [
            {
              title: "Total",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {filter_po_status: PurchaseOrderStatus.id_for(:processing)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {filter_po_status: PurchaseOrderStatus.id_for(:approved)}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end

      if user.vendor_payments_reviewer?
        reviewer_data = {
          type: "reviewer",
          data: [
            {
              title: "Awaiting Approval",
              count: PurchaseOrder.awaiting_action_items(user)&.count,
              filters: [{filter_awaiting_approval: true}]
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end