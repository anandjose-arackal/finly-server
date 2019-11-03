class Dashboard::VendorPayments::PurchaseOrders < Dashboard::VendorPayments::Base
  attr_accessor :purchase_orders

  def init
    # Set date filters
    params[:filter_creation_date_from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date_to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.purchase_orders = Procurements::PurchaseOrders::Index.(user, params).purchase_orders#.exclude_revision_of_po
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
    has_scope :filter_location_id
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
        filter_year: params[:filter_year],
        filter_location_id: params[:filter_location],
        filter_cost_center_id: params[:filter_cost_center]
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
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count,
              count: purchase_orders.filter_status('processing')&.count,
              filters: [
                {filter_status: 'processing'}
              ]
            },
            {
              title: "Approved",
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count,
              count: purchase_orders.filter_status('approved')&.count,
              filters: [
                {filter_status: 'approved'}
              ]
            },
            {
              title: "Sent to Vendor",
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor)})&.count,
              count: purchase_orders.filter_status('sent_to_vendor')&.count,
              filters: [
                {filter_status: 'sent_to_vendor'}
              ]
            },
            {
              title: "Vendor Confirmed",
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:vendor_confirmed)})&.count,
              count: purchase_orders.filter_status('vendor_confirmed')&.count,
              filters: [
                {filter_status: 'vendor_confirmed'}
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
              # count: apply_scopes(purchase_orders, {filter_user_id: user.id})&.count,
              count: purchase_orders.filter_user_id(user.id)&.count,
              filters: [
                {filter_user_id: user.id},
                {filter_user_name: user.name}
              ]
            },
            {
              title: "Processing",
              # count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:processing)})&.count,
              count: purchase_orders.filter_user_id(user.id).filter_status('processing')&.count,
              filters: [
                {filter_user_id: user.id},
                {filter_user_name: user.name},
                {filter_status: 'processing'}
              ]
            },
            {
              title: "Approved",
              # count: apply_scopes(purchase_orders, {filter_user_id: user.id, filter_status_id: PurchaseOrderStatus.id_for(:approved)})&.count
              count: purchase_orders.filter_user_id(user.id).filter_status('approved')&.count,
              filters: [
                {filter_user_id: user.id},
                {filter_user_name: user.name},
                {filter_status: 'approved'}
              ]
            },
            {
              title: "Sent to Vendor",
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:sent_to_vendor)})&.count,
              count: purchase_orders.filter_user_id(user.id).filter_status('sent_to_vendor')&.count,
              filters: [
                {filter_status: 'sent_to_vendor'}
              ]
            },
            {
              title: "Vendor Confirmed",
              # count: apply_scopes(purchase_orders, {filter_status_id: PurchaseOrderStatus.id_for(:vendor_confirmed)})&.count,
              count: purchase_orders.filter_user_id(user.id).filter_status('vendor_confirmed')&.count,
              filters: [
                {filter_status: 'vendor_confirmed'}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end


      # Set Date Filters in Filters
      # Done becauase the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
          if params[:filter_creation_date_from].present?
            date_filter_from = {filter_creation_date_from: params[:filter_creation_date_from]}
            data[:filters].push(date_filter_from)
          end

          if params[:filter_creation_date_to].present?
            date_filter_to = {filter_creation_date_to: params[:filter_creation_date_to]}
            data[:filters].push(date_filter_to)
          end
        end
      end

      # if user.is_purchase_order_reviewer?
      #   reviewer_data = {
      #     type: "reviewer",
      #     data: [
      #       {
      #         title: "Awaiting Approval",
      #         count: PurchaseOrder.awaiting_action_items(user)&.count,
      #         filters: [{filter_awaiting_approval: true}]
      #       }
      #     ]
      #   }
      #   self.counts.push(reviewer_data)
      # end
    end
  end
end