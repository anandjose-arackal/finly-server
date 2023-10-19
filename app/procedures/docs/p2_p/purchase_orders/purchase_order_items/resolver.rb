class Docs::P2P::PurchaseOrders::PurchaseOrderItems::Resolver < Resolver::API
  entity PurchaseOrderItem

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    po = Resolver::Router.dispatch('purchase_orders.default', { params: params, current_user: user })
    PurchaseOrderItem.where("purchase_order_id in (#{po.select('id').to_sql})").order(purchase_order_id: :asc)
  end
end
