class Procurements::PurchaseRequests::BulkRejectProcessor < BackgroundOperation
  attr_accessor :purchase_request_ids, :result

  def init
    self.purchase_request_ids = params[:purchase_request_ids]
    self.result = {
        success: [],
        error: []
    }
  end

  def validate
    if self.purchase_request_ids.blank?
      return
    end
  end

  def process
    purchase_request_ids.each do |id|
      data_success = {}
      data_error = {}
      op = Procurements::PurchaseRequests::Reject.(user, {purchase_request_id: id})
      pr = PurchaseRequest.find_by id: id
      unless op.success?
        data_error[:messages] = op.messages[:error]
        data_error[:order_number] = pr&.order_number
        data_error[:department] = pr&.department&.name
        data_error[:user] = pr&.user&.name
        data_error[:amount] = pr&.calculate_total_amount
        self.result[:error].push(data_error)
      else
        data_success[:order_number] = pr&.order_number
        data_success[:department] = pr&.department&.name
        data_success[:user] = pr&.user&.name
        data_success[:amount] = pr&.calculate_total_amount
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    # op = Event::EPurchaseRequest::BulkReject.(user, result: result)
  end
end
