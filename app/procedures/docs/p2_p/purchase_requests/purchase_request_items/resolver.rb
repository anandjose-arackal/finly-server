class Docs::P2P::PurchaseRequests::PurchaseRequestItems::Resolver < Resolver::API
  entity PurchaseRequestItem

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    pr = Resolver::Router.dispatch('purchase_requests.default', { params: params, current_user: user })
    PurchaseRequestItem.where "purchase_request_id  in (#{pr.select('id').to_sql})"
  end
end