class Docs::PaymentTickets::Resolver < Resolver::API

  entity BankPaymentRequest

  def load(params)
    if user.admin?(RequestStoreUtil.current_app.to_s)
      admin_restricted_status_ids = [BankPaymentRequestStatus.id_for(:open)]
      payment_tickets = ::BankPaymentRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.bank_payment_requests)
      return payment_tickets
    end

    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      payment_tickets = ::BankPaymentRequest.associated_items(user, ::BankPaymentRequest.roles)# || ::BankPaymentRequest.none
    else
      payment_tickets = ::BankPaymentRequest.none
    end
    payment_tickets
  end

end