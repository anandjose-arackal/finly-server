class Docs::P2P::PurchaseOrders::Resolver < Resolver::API

  entity PurchaseOrder

  def load(params)
    if user.vendor_payments_admin? or RequestStore.store[:vendor_manager]
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      purchase_orders = ::PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.purchase_orders)
      return purchase_orders
    end

    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      purchase_orders = ::PurchaseOrder.associated_items(user, ::PurchaseOrder.roles) || PurchaseOrder.none
    else
      purchase_orders = user.purchase_orders
    end

    return purchase_orders unless purchase_orders.nil?
    ::PurchaseOrder.none
  end


end