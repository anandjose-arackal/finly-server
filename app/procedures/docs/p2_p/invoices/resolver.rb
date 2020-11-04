class Docs::P2P::Invoices::Resolver < Resolver::API

  entity Invoice

  def load(params)
    invoices = nil
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [InwardInvoiceStatus.id_for(:open)]
      invoices = ::Invoice.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.inward_invoices)
      invoices = invoices.or(user.deactivated_users_open_invoices)
      return invoices.non_beneficiary.created_at_desc
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      invoices = ::Invoice.associated_items(user, ::Invoice.roles)
      invoices = invoices.non_beneficiary.created_at_desc rescue ::Invoice.none #unless invoices.blank?
    end

    return invoices unless invoices.nil?
    ::Invoice.none
  end


end