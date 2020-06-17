class Docs::P2P::Inwards::Received::Resolver < Resolver::API

  entity InwardDocument

  def load(params)
    policies = user.company.policies.joins(:policy_user_roles).where(policy_user_roles: {user_role_id: UserRole.id_for(:goods_receiver), user_id: user.id})
    InwardDocument.joins(procurement: :purchase_order).where("purchase_orders.policy_id IN (#{policies.select('id').to_sql})")
  end
end