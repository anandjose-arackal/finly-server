class Procurements::PurchaseRequests::BulkTakeControl < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests

  def init
    purchase_request_ids = params[:ids] || params[:purchase_request_ids]

    unless purchase_request_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.purchase_requests = user.company.purchase_requests.with_id(purchase_request_ids)
  end

  def validate
    if self.purchase_requests.empty?
      add_message :error, 'No Purchase Requests found'
      return
    end

    accept_pr = []
    self.purchase_requests.each do |purchase_request|
      valid = (purchase_request.can_take_control?) ? true : false

      if valid
        accept_pr << purchase_request.id
      end
    end
 
    self.purchase_requests = self.purchase_requests.where(id: accept_pr)

    if self.purchase_requests.blank?
      add_message :error, "None of the purchase requests are in a state to be in administrative control"
      return
    end

  end

  def process
    Procurements::PurchaseRequests::BulkTakeControlProcessor.call_async(user.id, {purchase_request_ids: purchase_requests.pluck(:id)})
  end

  def post_process
    add_message :success, "Taking control of multiple purchase requests (#{self.purchase_requests.length}). You will be notified via mail once all are done."
  end
end
