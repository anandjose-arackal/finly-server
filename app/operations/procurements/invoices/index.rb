class Procurements::Invoices::Index < Procurements::Invoices::Base
  attr_accessor :invoices, :policies
  def init
  end

  def validate
  end

  def process
    # # Only used for getting pending approval
    # if user.vendor_payments_reviewer?
    #   self.invoices = Invoice.awaiting_action_items(user)
    # end

    if user.vendor_payments_admin?
      admin_restricted_status_ids = [InwardInvoiceStatus.id_for(:open)]
      self.invoices = ::Invoice.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.inward_invoices)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.invoices = ::Invoice.associated_items(user, ::Invoice.roles) || Invoice.none
    else
      self.invoices = user.inward_invoices
    end
  end

  def success
    params[:invoices] = self.invoices
    Procurements::Invoices::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoices

    has_scope :filter_inward_invoice_type
    has_scope :filter_awaiting_approval
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_user
    has_scope :filter_vendor_id

    def init
      self.invoices = params[:invoices]

      self.invoices = apply_scopes(self.invoices, params)
    end

  end
end