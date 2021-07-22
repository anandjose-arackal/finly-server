class Docs::P2P::PurchaseRequests::PurchaseRequestItems::Resolver < Resolver::API
  entity PurchaseRequestItem

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    pr = Resolver::Router.dispatch('purchase_requests.default', { params: params, current_user: user })
    # PurchaseRequestStatus::GROUP_APPROVED_ITEM applying against item instead of pr, other filters against parent
     if params.with_indifferent_access.dig(:qs, :with_status_ids) == PurchaseRequestStatus::GROUP_APPROVED_ITEM
       PurchaseRequestItem.where "purchase_request_id  in (#{pr.select('id').to_sql}) and purchase_request_items.status_id = #{PurchaseRequestItemStatus.id_for(:approved)} and purchase_request_items.rejected = false"
     else
       PurchaseRequestItem.where "purchase_request_id  in (#{pr.select('id').to_sql})"
     end
  end
end