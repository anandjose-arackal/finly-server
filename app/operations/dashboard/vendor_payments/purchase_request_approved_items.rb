class Dashboard::VendorPayments::PurchaseRequestApprovedItems < Dashboard::VendorPayments::Base
  attr_accessor :approved_purchase_request_items, :purchase_requests

  def init
    # Set Date Filters
    params[:filter_by_date_range] = {}
    params[:filter_by_date_range][:from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_by_date_range][:to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.approved_purchase_request_items = Procurements::PurchaseRequests::ApprovedItems.(user, params).approved_purchase_request_items
  end

  def success
    params[:approved_purchase_request_items] = self.approved_purchase_request_items
    # self.params[:purchase_requests] = self.purchase_requests
    Dashboard::VendorPayments::PurchaseRequestApprovedItems::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PurchaseRequestApprovedItems::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests, :counts, :approved_purchase_request_items

    has_scope :filter_status_id
    has_scope :filter_user_id

    # General Filters from frontend
    has_scope :filter_policy_id
    has_scope :filter_location_id
    has_scope :filter_department_id
    has_scope :filter_month
    has_scope :filter_year


    def init
      general_filter_params = {
          filter_policy_id: params[:filter_policy],
          filter_department_id: params[:filter_department],
          filter_month: params[:filter_month],
          filter_year: params[:filter_year],
          filter_location_id: params[:filter_location]
      }

      # self.purchase_requests = params[:purchase_requests]
      # self.purchase_requests = apply_scopes(self.purchase_requests, general_filter_params)
      self.approved_purchase_request_items = params[:approved_purchase_request_items]
      self.approved_purchase_request_items = apply_scopes(self.approved_purchase_request_items)

      self.counts = []

      if user.vendor_payments_admin?
        approved_items_data = {
            type: 'admin',
            data: [
                {
                    title: "Total",
                    count: apply_scopes(self.approved_purchase_request_items)&.count,
                    filters: [
                        {}
                    ]
                }
            ]
        }
        self.counts.push(approved_items_data)
      end


      if user.is_purchase_order_initiator? || user.is_inventory_manager?
        approved_items_data = {
            type: 'personal',
            data: [
                {
                    title: "Total",
                    count: self.approved_purchase_request_items.role_based_filter(true)&.count,
                    filters: [
                        {role_based_filter: true}
                    ]
                }
            ]
        }
        self.counts.push(approved_items_data)
      end

      # Set Date Filters in Filters
      # Done because the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
          if params[:filter_by_date_range].present? && params[:filter_by_date_range][:from].present?
            filter_date = {'filter_by_date_range[from]': params[:filter_by_date_range][:from]}
            data[:filters].push(filter_date)
          end

          if params[:filter_by_date_range].present? && params[:filter_by_date_range][:to].present?
            filter_date = {'filter_by_date_range[to]': params[:filter_by_date_range][:to]}
            data[:filters].push(filter_date)
          end
        end
      end
    end
  end
end