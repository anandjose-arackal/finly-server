# this operation will take a bunch of payment request IDs and take control of them one by one
# if validation passes

class BankTransfer::PaymentRequest::Review::BulkTakeControl < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests

  def init
    ids = params["bulk_take_control_ids"]
    unless ids.is_a?(Array)
      ids = ids.split(',')
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_requests.includes_details
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
      puts "Payment orders not found"
    end

    unless user.vendor_payment_admin?
      add_message :error, "Only admins can take control of a report"
      puts "Only admins can take control of a report"
      return
    end

    reject_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = true
      unless bank_payment_request.can_take_control?
        # add_message :error, "Payment requets cannot be taken control of at this stage"
        valid = false
      end

      if bank_payment_request.controlling_for_user.present?
        # add_message :error, "Payment requets already in control for #{bank_payment_request.id}"
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
  end

  def process
    # self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:processing))
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    # ids = self.bank_payment_requests.pluck(:id)
    ids = self.bank_payment_requests.map { |h| h[:id] }
    BankTransfer::PaymentRequest::Review::BulkTakeControlBackground.call_async(ids, {initiating_user_id: current_user.id, bulk_take_control_ids: params["bulk_take_control_ids"]})
    # BankTransfer::PaymentRequest::Review::BulkTakeControlBackground.call(ids, {initiating_user_id: user.id, params: params[:bulk_take_control_ids]})
  end

end
