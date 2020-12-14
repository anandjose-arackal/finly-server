class Docs::P2P::PurchaseOrders::PurchaseOrderItems::Resolver < Resolver::API
  entity PurchaseOrderItem

  def load(params)
    po = Resolver::Router.dispatch('purchase_orders.default', { params: params, current_user: user })
    PurchaseOrderItem.where "purchase_order_id in (#{po.select('id').to_sql})"
  end
end
