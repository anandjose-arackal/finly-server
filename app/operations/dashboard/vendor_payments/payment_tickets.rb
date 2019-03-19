class Dashboard::VendorPayments::PaymentTickets < Dashboard::VendorPayments::Base
  attr_accessor :payment_tickets

  def init
    self.payment_tickets = BankTransfer::PaymentRequest::Index.(user, params).payment_requests
  end

  def success
    params[:payment_tickets] = self.payment_tickets
    Dashboard::VendorPayments::PaymentTickets::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PaymentTickets::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_tickets, :counts

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

      self.payment_tickets = params[:payment_tickets]
      self.payment_tickets = apply_scopes(self.payment_tickets, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin?
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
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:processing)})&.count,
              filters: [
                {filter_status_id: BankPaymentRequestStatus.id_for(:processing)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:approved)})&.count,
              filters: [
                {filter_status_id: BankPaymentRequestStatus.id_for(:approved)}
              ]
            },
            {
              title: "Credited",
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:credited)})&.count,
              filters: [
                {filter_status_id: BankPaymentRequestStatus.id_for(:credited)}
              ]
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.vendor_payment_initiator?
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
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status_id: BankPaymentRequestStatus.id_for(:processing)})&.count,
              filters: [
                {filter_status_id: BankPaymentRequestStatus.id_for(:processing)},
                {filter_user_name: user.name},
                {filter_user_id: user.id}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status_id: BankPaymentRequestStatus.id_for(:approved)})&.count,
              filters: [
                {filter_status_id: BankPaymentRequestStatus.id_for(:approved)},
                {filter_user_name: user.name},
                {filter_user_id: user.id}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end

      if user.vendor_payments_reviewer?
        reviewer_data = {
          type: "reviewer",
          title: "Teams' Payment Tickets",
          data: [
            {
              title: "Awaiting Approval",
              count: BankPaymentRequest.awaiting_action_items(user)&.count,
              filters: [
                {filter_status_id: 10}
              ]
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end