# this operation will take a bunch of payment request IDs and reject them one by one

class BankTransfer::PaymentRequest::Review::BulkReject < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def pre_validate
    super
    return if has_errors?
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this action'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    ids = params[:ids] || params[:bank_payment_request_ids] || params[:payment_request_ids]
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

    reject_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = true
      unless bank_payment_request.can_reject?
        # add_message :error, "Payment requets cannot be rejected at this stage"
        valid = false
      end

      unless valid
        reject_bpr << bank_payment_request
      end
    end

    self.bank_payment_requests = self.bank_payment_requests.reject do |all_bpr|
        reject_bpr.any? do |bpr|
            all_bpr.id == bpr.id
        end
    end

    if self.bank_payment_requests.blank?
      add_message :error, "None of the payment tickets are in a state to be rejected"
      return
    end

  end

  def process
    # update the status of all payment orders as pending
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)
    BankTransfer::PaymentRequest::Review::ApproveBackground.call_async(ids, initiating_user_id: user.id)
    # op = BankTransfer::PaymentRequest::Review::ApproveBackground.call(ids, initiating_user_id: user.id)
  end


end