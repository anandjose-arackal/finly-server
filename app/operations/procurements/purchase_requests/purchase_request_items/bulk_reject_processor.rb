class Procurements::PurchaseRequests::PurchaseRequestItems::BulkRejectProcessor < BackgroundOperation
  attr_accessor :purchase_request_item_ids, :result

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
      op = ::Procurements::PurchaseRequests::PurchaseRequestItems::Reject.(user, {purchase_request_item_id: id})
      purchase_request_item = PurchaseRequestItem.find_by id: id
      unless op.success?
        data_error[:messages] = op.messages[:error]
        data_error[:purchase_request_item_id] = purchase_request_item&.id
        self.result[:error].push(data_error)
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
