class Dashboard::VendorPayments::UtilityBills < Dashboard::VendorPayments::Base
  attr_accessor :utility_bills

  def init
    # Set date filters
    params[:filter_creation_date_from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date_to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.utility_bills = Docs::UtilityBills::Bills::Ops::Index.(params: params, current_user: user)['result']&.dig('bills')
  end

  def success
    params[:utility_bills] = self.utility_bills
    Dashboard::VendorPayments::UtilityBills::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::UtilityBills::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :utility_bills, :counts

    has_scope :filter_status
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
          filter_location_id: params[:filter_location],
          filter_cost_center_id: params[:filter_cost_center]
      }

      self.utility_bills = params[:utility_bills]
      self.utility_bills = apply_scopes(self.utility_bills, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
            type: 'admin',
            data: [
                {
                    title: "Total",
                    count: utility_bills.count,
                    filters: []
                },
                {
                    title: "Processing",
                    count: utility_bills.filter_status('processing')&.count,
                    filters: [
                        {filter_status: 'processing'}
                    ]
                },
                {
                    title: "Failed",
                    count: utility_bills.filter_status('failed')&.count,
                    filters: [
                        {filter_status: 'failed'}
                    ]
                },
                {
                    title: "Overdue",
                    count: utility_bills.filter_overdue(true)&.count,
                    filters: [
                        {filter_overdue: true}
                    ]
                },
                {
                    title: "Paid",
                    count: utility_bills.filter_status('paid')&.count,
                    filters: [
                        {filter_status: 'paid'}
                    ]
                }
            ]
        }

        self.counts.push(admin_data)
      end

      if user.is_utility_bill_initiator?
        personal_data = {
            type: 'personal',
            data: [
                {
                    title: "Total",
                    count: utility_bills.filter_user_id(user.id)&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name}
                    ]
                },
                {
                    title: "Awaiting Action",
                    count: utility_bills.filter_poc_awaiting_action(user.id)&.count,
                    filters: [
                        {filter_poc_awaiting_action: user.id}
                    ]
                },
                {
                    title: "Processing",
                    count: utility_bills.filter_user_id(user.id).filter_status('processing')&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name},
                        {filter_status: 'processing'}
                    ]
                },
                {
                    title: "Approved",
                    count: utility_bills.filter_user_id(user.id).filter_status('approved')&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name},
                        {filter_status: 'approved'}
                    ]
                },
                {
                    title: "Rejected",
                    count: utility_bills.filter_user_id(user.id).filter_status('rejected')&.count,
                    filters: [
                        {filter_status: 'rejected'}
                    ]
                },
                {
                    title: "Retracted",
                    count: utility_bills.filter_user_id(user.id).filter_status('retracted')&.count,
                    filters: [
                        {filter_status: 'retracted'}
                    ]
                }
            ]
        }
        self.counts.push(personal_data)
      end

      if user.is_bank_payment_request_initiator?
        creditor_data = {
            type: 'creditor',
            data: [
                {
                    title: "Awaiting Payment",
                    count: utility_bills.filter_payable_bills(true)&.count,
                    filters: []
                },
                {
                    title: "Payment Ticket Created",
                    count: utility_bills.filter_status('payment_ticket_created')&.count,
                    filters: [
                        {filter_status: 'payment_ticket_created'}
                    ]
                },
                {
                    title: "Payment Processing",
                    count: utility_bills.filter_status('payment_initiated')&.count,
                    filters: [
                        {filter_status: 'payment_initiated'}
                    ]
                },
                {
                    title: "Overdue",
                    count: utility_bills.filter_overdue(true)&.count,
                    filters: [
                        {filter_overdue: true}
                    ]
                },
                {
                    title: "Paid",
                    count: utility_bills.filter_status('paid')&.count,
                    filters: [
                        {filter_status: 'paid'}
                    ]
                },
                {
                    title: "Failed",
                    count: utility_bills.filter_status('failed')&.count,
                    filters: [
                        {filter_status: 'failed'}
                    ]
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