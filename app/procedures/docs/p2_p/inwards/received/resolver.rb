class Docs::P2P::Inwards::Received::Resolver < Resolver::API

  entity InwardDocument

  def load(params)
    if user.vendor_payment_admin?
      policies = user.company.policies
    else
      policies = user.company.policies.joins(:policy_user_roles).where(policy_user_roles: {user_role_id: UserRole.id_for(:goods_receiver), user_id: user.id})
    end
    InwardDocument.joins(procurement: :purchase_order).where("purchase_orders.policy_id IN (#{policies.select('id').to_sql})")
  end
end