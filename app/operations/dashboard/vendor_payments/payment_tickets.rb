class Dashboard::VendorPayments::PaymentTickets < Dashboard::VendorPayments::Base
  attr_accessor :payment_tickets

  def init
    # Set date filters
    params[:filter_date] = {}
    params[:filter_date][:from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_date][:to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.payment_tickets = BankTransfer::PaymentRequest::Index.(user, params).payment_requests
  end

  def success
    params[:payment_tickets] = self.payment_tickets
    Dashboard::VendorPayments::PaymentTickets::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PaymentTickets::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_tickets, :counts

    has_scope :filter_status
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
        # filter_department_id: params[:filter_department],
        # filter_sub_department_id: params[:filter_sub_department],
        filter_month: params[:filter_month],
        filter_year: params[:filter_year]
      }

      self.payment_tickets = params[:payment_tickets]
      self.payment_tickets = apply_scopes(self.payment_tickets, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin? || user.is_bank_payment_request_auditor?
        admin_data = {
          type: 'admin',
          title: "Company Payment Tickets",
          data: [
            {
              title: "Total",
              count: payment_tickets.count,
              filters: []
            },
            {
              title: "Processing",
              count: apply_scopes(payment_tickets, {filter_status: 'processing'})&.count,
              filters: [
                {filter_status: 'processing'}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_status: 'approved'})&.count,
              filters: [
                {filter_status: 'approved'}
              ]
            },
            {
              title: "Credited",
              count: apply_scopes(payment_tickets, {filter_status: 'credited'})&.count,
              filters: [
                {filter_status: 'credited'}
              ]
            },
            {
              title: "In Progress",
              count: apply_scopes(payment_tickets, {filter_status: 'in_progress'})&.count,
              filters: [
                {filter_status: 'in_progress'}
              ]
            },
            {
              title: "Partially Completed",
              count: apply_scopes(payment_tickets, {filter_status: 'partially_completed'})&.count,
              filters: [
                {filter_status: 'partially_completed'}
              ]
            },

            {
              title: "Completed",
              count: apply_scopes(payment_tickets, {filter_status: 'completed'})&.count,
              filters: [
                {filter_status: 'completed'}
              ]
            },
            {
              title: "Failed",
              count: apply_scopes(payment_tickets, {filter_status: 'failed'})&.count,
              filters: [
                {filter_status: 'failed'}
              ]
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.is_bank_payment_request_initiator?
        personal_data = {
          type: 'personal',
          title: "My Payment Tickets",
          data: [
            {
              title: "Total",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id})&.count,
              filters: [
                {filter_user_name: user.name},
                {filter_user_id: user.id}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'processing'})&.count,
              filters: [
                {filter_status: 'processing'},
                {filter_user_name: user.name},
                {filter_user_id: user.id}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'approved'})&.count,
              filters: [
                {filter_status: 'approved'},
                {filter_user_name: user.name},
                {filter_user_id: user.id}
              ]
            },
            {
              title: "Credited",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'credited'})&.count,
              filters: [
                {filter_status: 'credited'}
              ]
            },
            {
              title: "In Progress",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'in_progress'})&.count,
              filters: [
                {filter_status: 'in_progress'}
              ]
            },
            {
              title: "Partially Completed",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'partially_completed'})&.count,
              filters: [
                {filter_status: 'partially_completed'}
              ]
            },

            {
              title: "Completed",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'completed'})&.count,
              filters: [
                {filter_status: 'completed'}
              ]
            },
            {
              title: "Failed",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'failed'})&.count,
              filters: [
                {filter_status: 'failed'}
              ]
            }
          ]       
        }
        self.counts.push(personal_data)

      end

      # Set Date Filters in Filters
      # Done because the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
           if params[:filter_date].present? && params[:filter_date][:from].present?
             filter_date = {'filter_date[from]': params[:filter_date][:from]}
             data[:filters].push(filter_date)
           end

          if params[:filter_date].present? && params[:filter_date][:to].present?
             filter_date = {'filter_date[to]': params[:filter_date][:to]}
             data[:filters].push(filter_date)
           end
        end
      end

    #   if user.vendor_payments_reviewer?
    #     reviewer_data = {
    #       type: "reviewer",
    #       title: "Teams' Payment Tickets",
    #       data: [
    #         {
    #           title: "Awaiting Approval",
    #           count: BankPaymentRequest.awaiting_action_items(user)&.count,
    #           filters: [
    #             {filter_status: 10}
    #           ]
    #         }
    #       ]
    #     }
    #     self.counts.push(reviewer_data)
    #   end
    end

    def payment_ticket_dashboard_data
      [
        {
          title: "Total",
          count: apply_scopes(payment_tickets, {filter_user_id: user.id})&.count,
          filters: [
            {filter_user_name: user.name},
            {filter_user_id: user.id}
          ]
        },
        {
          title: "Processing",
          count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'processing'})&.count,
          filters: [
            {filter_status: 'processing'},
            {filter_user_name: user.name},
            {filter_user_id: user.id}
          ]
        },
        {
          title: "Approved",
          count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status: 'approved'})&.count,
          filters: [
            {filter_status: 'approved'},
            {filter_user_name: user.name},
            {filter_user_id: user.id}
          ]
        },
        {
          title: "Credited",
          count: apply_scopes(payment_tickets, {filter_status: 'credited'})&.count,
          filters: [
            {filter_status: 'credited'}
          ]
        },
        {
          title: "In Progress",
          count: apply_scopes(payment_tickets, {filter_status: 'in_progress'})&.count,
          filters: [
            {filter_status: 'in_progress'}
          ]
        },
        {
          title: "Partially Completed",
          count: apply_scopes(payment_tickets, {filter_status: 'partially_completed'})&.count,
          filters: [
            {filter_status: 'partially_completed'}
          ]
        },

        {
          title: "Completed",
          count: apply_scopes(payment_tickets, {filter_status: 'completed'})&.count,
          filters: [
            {filter_status: 'completed'}
          ]
        },
        {
          title: "Failed",
          count: apply_scopes(payment_tickets, {filter_status: 'failed'})&.count,
          filters: [
            {filter_status: 'failed'}
          ]
        }
      ]
    end
  end
end