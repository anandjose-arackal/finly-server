class Docs::P2P::PurchaseRequests::PurchaseRequestItems::Resolver < Resolver::API
  entity PurchaseOrderItem

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    po = Resolver::Router.dispatch('purchase_requests.default', { params: params, current_user: user })
    PurchaseOrderItem.where "purchase_order_id in (#{po.select('id').to_sql})"
  end
end