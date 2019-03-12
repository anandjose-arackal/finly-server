class Dashboard::VendorPayments::Invoices < Dashboard::VendorPayments::Base
  attr_accessor :payment_tickets

  def init
    self.payment_tickets = Procurements::Invoices::Index.(user, params).payment_requests
  end

  def success
    params[:payment_tickets] = self.payment_tickets
    Dashboard::VendorPayments::PurchaseOrders::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PaymentTickets::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_tickets, :counts

    has_scope :filter_status_id
    has_scope :filter_user_id

    def init
      self.payment_tickets = params[:payment_tickets]
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: payment_tickets.count
            },
            {
              title: "Processing",
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:approved)})&.count
            },
            {
              title: "Credited",
              count: apply_scopes(payment_tickets, {filter_status_id: BankPaymentRequestStatus.id_for(:credited)})&.count
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
              count: apply_scopes(payment_tickets, {filter_user_id: user.id})&.count
            },
            {
              title: "Processing",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status_id: BankPaymentRequestStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(payment_tickets, {filter_user_id: user.id, filter_status_id: BankPaymentRequestStatus.id_for(:approved)})&.count
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
              count: BankPaymentRequest.awaiting_action_items(user)&.count
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end