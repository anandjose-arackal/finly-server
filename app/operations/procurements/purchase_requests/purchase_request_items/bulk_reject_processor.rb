class Procurements::PurchaseRequests::PurchaseRequestItems::BulkRejectProcessor < BackgroundOperation
  attr_accessor :purchase_request_item_ids, :result, :purchase_request_item

  def init
    self.purchase_request_item_ids = params[:purchase_request_item_ids]
    self.result = {
        success: [],
        error: []
    }
  end

  def validate
    if self.purchase_request_item_ids.blank?
      return
    end
  end

  def process
    purchase_request_item_ids.each do |id|
      data_success = {}
      data_error = {}
      # op = ::Procurements::PurchaseRequests::PurchaseRequestItems::Reject.(user, {purchase_request_item_id: id})
      self.purchase_request_item = PurchaseRequestItem.find_by id: id
      self.purchase_request_item.status_id = PurchaseRequestItemStatus.id_for(:rejected)
      self.purchase_request_item.rejected = true
      unless purchase_request_item.save
        data_error[:messages] = op.messages[:error]
        data_error[:purchase_request_item_id] = purchase_request_item&.id
        self.result[:error].push(data_error)
        # If any line item fails, the status remains approved or auto_approved
        # Use that status to rollback
        PurchaseRequestItem.where(id: purchase_request_item_ids).update_all(status_id: purchase_request_item.status_id, rejected: false)
        break
      else
        data_success[:purchase_request_item_id] = purchase_request_item&.id
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    # Notifications to be done later
  end
end
