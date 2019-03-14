class Dashboard::VendorPayments::Invoices < Dashboard::VendorPayments::Base
  attr_accessor :invoices

  def init
    self.invoices = Procurements::Invoices::Index.(user, params).invoices
  end

  def success
    params[:invoices] = self.invoices
    Dashboard::VendorPayments::Invoices::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::Invoices::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoices, :counts

    has_scope :filter_status
    has_scope :with_created_by_user_id
    has_scope :filter_inward_invoice_type

    def init
      self.invoices = params[:invoices]
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: invoices.count
            },
            {
              title: "Processing",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:approved)})&.count
            },
            {
              title: "Credited",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:credited)})&.count
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.is_invoice_initiator?
        personal_data = {
          type: 'personal',
          data: [
            {
              title: "Total",
              count: apply_scopes(invoices, {with_created_by_user_id: user.id})&.count
            },
            {
              title: "Processing",
              count: apply_scopes(invoices, {with_created_by_user_id: user.id, filter_status_id: InwardInvoiceStatus.id_for(:processing)})&.count
            },
            {
              title: "Approved",
              count: apply_scopes(invoices, {with_created_by_user_id: user.id, filter_status_id: InwardInvoiceStatus.id_for(:approved)})&.count
            }
          ]
        }
        self.counts.push(personal_data)
      end

      if user.is_invoice_reviewer?
        awaiting_invoices = Invoice.awaiting_action_items(user)
        reviewer_data = {
          type: "reviewer",
          data: [
            {
              title: "Awaiting Approval",
              count: apply_scopes(awaiting_invoices, {filter_inward_invoice_type: params[:filter_inward_invoice_type]})&.count
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end