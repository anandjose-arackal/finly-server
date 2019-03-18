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

    has_scope :filter_status_id
    has_scope :with_created_by_user_id
    has_scope :filter_inward_invoice_type

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

      self.invoices = params[:invoices]
      self.invoices = apply_scopes(self.invoices, general_filter_params)
      self.counts = []

      if params[:action] == 'non_po_invoices'
        invoice_type = 'non_po_invoices'
      elsif params[:action] == 'po_invoice'
        invoice_type = 'po_invoice'
      else
        # nothin
      end
          

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: invoices.count,
              filters: [
                {filter_invoice_type: invoice_type}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:processing)})&.count,
              filters: [
                {filter_invoice_type: invoice_type},
                {filter_status: "processing"}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:approved)})&.count,
              filters: [
                {filter_invoice_type: invoice_type},
                {filter_status: "approved"}
              ]
            },
            {
              title: "Credited",
              count: apply_scopes(invoices, {filter_status_id: InwardInvoiceStatus.id_for(:credited)})&.count,
              filters: [
                {filter_invoice_type: invoice_type},
                {filter_status: "paid"}
              ]
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
              count: apply_scopes(invoices, {with_created_by_user_id: user.id})&.count,
              filter: [
                {filter_invoice_type: invoice_type},
                {filter_user: true}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(invoices, {with_created_by_user_id: user.id, filter_status_id: InwardInvoiceStatus.id_for(:processing)})&.count,
              filter: [
                {filter_invoice_type: invoice_type},
                {filter_user: true},
                {filter_status: "processing"}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(invoices, {with_created_by_user_id: user.id, filter_status_id: InwardInvoiceStatus.id_for(:approved)})&.count,
              filter: [
                {filter_invoice_type: invoice_type},
                {filter_user: true},
                {filter_status: "approved"}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end

      if user.is_invoice_reviewer? && user.is_bank_payment_request_creditor?
        awaiting_invoices = Invoice.awaiting_action_items(user)
        data = {
          type: "reviewer",
          data: [
            {
              title: "Awaiting Approval",
              count: apply_scopes(awaiting_invoices, {filter_inward_invoice_type: params[:filter_inward_invoice_type]})&.count,
              filters: [
                {filter_invoice_type: invoice_type},
                {filter_awaiting_approval: true}
              ]
            }
          ]
        }
        self.counts.push(data)
      end
    end
  end
end