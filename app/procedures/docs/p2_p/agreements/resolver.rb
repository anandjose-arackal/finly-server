class Docs::P2P::Agreements::Resolver < Resolver::API

  entity PaymentAgreement

  def load(params)
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [PaymentAgreementStatus.id_for(:draft)]
      payment_agreements = ::PaymentAgreement.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})
      return user.payment_agreements.or(payment_agreements)
    end

    return user.payment_agreements if user.policy_user_roles.pluck(:user_role_id).uniq.blank?

    ::PaymentAgreement.associated_items(user, ::PaymentAgreement.agreement_master_roles) || PaymentAgreement.none
  end


end