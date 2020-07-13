# this operation will take a bunch of payment request IDs and approve them one by one
# if they're approvable

class BankTransfer::PaymentRequest::Review::BulkApprove < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def init
    ids = params[:id] || params[:ids] || params[:bank_payment_request_ids] || params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(',')
    end

    bprs = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil

    # Extracting BPRs with Ids from index operation as Mysql update statement cannot have a select statement using the target table
    # https://dev.mysql.com/doc/refman/5.6/en/update.html
    # ERROR 1093 (HY000): You can't specify target table 'items' for update in FROM clause

    self.bank_payment_requests = BankPaymentRequest.with_id(bprs&.pluck(:id))
    self.bank_payment_requests = self.bank_payment_requests.includes_details
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
    end

    accept_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = (bank_payment_request.can_really_approve?) ? true : false

      if valid
        accept_bpr << bank_payment_request.id
      end
    end
 
    self.bank_payment_requests = self.bank_payment_requests.where(id: accept_bpr)

    if self.bank_payment_requests.blank?
      add_message :error, "None of the payment tickets are in a state to be approved."
      return
    end
  end

  def process
    # update the status of all payment orders as pending
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    # ids = self.bank_payment_requests.pluck(:id)
    ids = self.bank_payment_requests.map { |b| b[:id] }
    BankTransfer::PaymentRequest::Review::ApproveBackground.call_async(ids, initiating_user_id: user.id)
    # op = BankTransfer::PaymentRequest::Review::ApproveBackground.call(ids, initiating_user_id: user.id)
  end

  def post_process
    add_message :success, "Your request for approving #{self.bank_payment_requests.length} payment tickets is being processed."
  end


end