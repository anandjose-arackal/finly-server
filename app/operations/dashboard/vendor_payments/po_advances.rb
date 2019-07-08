class Dashboard::VendorPayments::POAdvances < Dashboard::VendorPayments::Base
  attr_accessor :purchase_orders

  def init
    params[:filter_po_advances]
    # Set date filters
    params[:filter_creation_date_from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date_to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.purchase_orders = Procurements::PurchaseOrders::Index.(user, params).purchase_orders
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Dashboard::VendorPayments::POAdvances::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::POAdvances::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders, :counts

    has_scope :filter_all_advances, type: :boolean
    has_scope :filter_payable_advances, type: :boolean

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
              title: "Initiated",
              # count: apply_scopes(purchase_orders, {filter_all_advances: true, filter_po_advance_status: 'initiated'})&.count,
              count: purchase_orders.filter_all_advances.filter_po_advance_status('initiated')&.count,
              filters: [{filter_po_advance_status: 'initiated'}]
            },
            {
              title: "To Be Processed",
              # count: apply_scopes(purchase_orders, {filter_all_advances: true, filter_po_advance_status: 'to_be_processed'})&.count,
              count: purchase_orders.filter_all_advances.filter_po_advance_status('to_be_processed')&.count,
              filters: [{filter_po_advance_status: 'to_be_processed'}]
            }
          ]
        }
        self.counts.push(creditor_data)
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
    end
  end
end