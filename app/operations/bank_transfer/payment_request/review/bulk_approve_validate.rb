# this operation will take a bunch of ids and mention whether the respective payment orders can be approved
# it essentially checks for the state of the payment orders and return true or false

class BankTransfer::PaymentRequest::Review::BulkApproveValidate < BankTransfer::PaymentRequest::Review::Base

  class BankTransfer::PaymentRequest::Review::BulkApprove::ApprovePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :errors_found, :validate_result

    def init
      self.errors_found = params[:errors_found]
      self.validate_result = params[:validate_result]
    end

  end

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def init
    ids = params[:ids] || params[:bank_payment_request_ids]
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_request.includes_details
    self.processing_status_id = BankPaymentRequestStatus.id_for(:processing)
    self.errors_found = false
    self.validate_result = []
  end

  def validate
    unless bank_payment_requests.present?
      add_message :error, "Payment orders to process not found"
    end
  end

  def process
    self.bank_payment_requests.each do |payment_request|
      errors = []
      if payment_request.status_id != self.processing_status_id
        errors << "Payment order cannot be approved in this state"
        self.errors_found = true
      end
      unless payment_request.controlling_user_id == user.id
        errors << "You are not authorized to approve this payment order"
        self.errors_found = true
      end
      self.validate_result << {
          user: payment_request.user,
          name: payment_request.name,
          amount: payment_request.requested_amount&.value,
          errors: errors,
          valid: (errors.empty? ? true : false)
      }
    end
  end

  def success
    params[:errors_found] = self.errors_found,
    params[:validate_result] = self.validate_result
    BankTransfer::PaymentRequest::Review::BulkApprove::ApprovePresenter.new(user, params, messages)
  end

end
