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

    def init
      self.purchase_orders = params[:purchase_orders]
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: purchase_orders.count
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count
            },
            {
              title: "Sent to Vendor",
              count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor)})&.count
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.vendor_payment_initiator?
        personal_data = {
          type: 'personal',
          data: [
            {
              title: "Total",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id})&.count
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count
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
              count: PurchaseOrder.awaiting_action_items(user)&.count
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end