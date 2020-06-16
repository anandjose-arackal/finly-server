class Docs::P2P::PurchaseRequests::Resolver < Resolver::API

  entity PurchaseRequest

  def load(params)
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [PurchaseRequestStatus.id_for(:draft)]
      # self.purchase_requests = user.company.purchase_requests.with_ids(::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}) )
      purchase_requests = ::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})
      purchase_requests = user.purchase_requests.or(purchase_requests)
      return purchase_requests
    end

    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      purchase_requests = ::PurchaseRequest.associated_items(user, ::PurchaseRequest.roles) || PurchaseRequest.none
    else
      purchase_requests = user.purchase_requests
    end

    if purchase_requests.nil?
      purchase_requests = ::PurchaseRequest.none
    end

    purchase_requests
  end

end