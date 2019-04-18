class Procurements::PurchaseRequests::RejectApprovedItems < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests, :purchase_request_items

  def init

    item_ids = params[:item_ids][0].split(',') || params[:ids]
    unless item_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.purchase_request_items = ::Procurements::PurchaseRequests::ApprovedItems.(user, params).approved_purchase_request_items.with_ids(item_ids)
  end

  def validate
    if self.purchase_request_items.empty?
      add_message :error, 'No purchase request items found'
    end
  end

  def process
    ::Procurements::PurchaseRequests::PurchaseRequestItems::BulkRejectProcessor.call_async(user.id, {purchase_request_item_ids: purchase_request_items.pluck(:id)})
  end

  def post_process
    add_message :success, "Rejecting multiple approved items (#{self.purchase_request_items.length})."
  end
end