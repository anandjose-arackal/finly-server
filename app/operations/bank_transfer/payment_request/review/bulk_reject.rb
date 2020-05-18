# this operation will take a bunch of payment request IDs and reject them one by one

class BankTransfer::PaymentRequest::Review::BulkReject < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def init
    ids = params[:id] || params[:ids] || params[:bank_payment_request_ids] || params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(',')
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_requests.includes_details
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
    end

    accept_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = (bank_payment_request.can_really_reject?) ? true : false

      if valid
        accept_bpr << bank_payment_request.id
      end
    end
 
    self.bank_payment_requests = self.bank_payment_requests.where(id: accept_bpr)

    if self.bank_payment_requests.blank?
      add_message :error, "None of the payment tickets are in a state to be rejected"
      return
    end

  end

  def process
    # update the status of all payment orders as pending
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)
    BankTransfer::PaymentRequest::Review::BulkRejectBackground.call_async(ids, initiating_user_id: user.id)
    # op = BankTransfer::PaymentRequest::Review::ApproveBackground.call(ids, initiating_user_id: user.id)
  end

  def post_process
    add_message :success, "Your request for rejecting #{self.bank_payment_requests.length} payment tickets is being processed."
  end


end