# this operation will take a bunch of ids and mention whether the respective payment orders can be approved
# it essentially checks for the state of the payment orders and return true or false

class BankTransfer::PaymentRequest::Review::BulkApproveValidate < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :processable_amount, :unprocessable_amount

  class BankTransfer::PaymentRequest::Review::BulkApprove::ApprovePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :errors_found, :validate_result, :processable_amount, :unprocessable_amount

    def init
      self.errors_found = params[:errors_found]
      self.validate_result = params[:validate_result]
      self.processable_amount = params[:processable_amount]
      self.unprocessable_amount = params[:unprocessable_amount]
    end

  end

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result, :processing_status_ids

  def init
    ids = params[:ids] || params[:bank_payment_request_ids] || params[:payment_request_ids]
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_requests.includes_details
    self.processing_status_id = BankPaymentRequestStatus.id_for(:processing)
    self.processing_status_ids = [BankPaymentRequestStatus.id_for(:processing), BankPaymentRequestStatus.id_for(:pending)]
    self.errors_found = false
    self.validate_result = []
  end

  def validate
    unless bank_payment_requests.present?
      add_message :error, "Payment orders to process not found"
    end
  end

  def process
    self.processable_amount = self.unprocessable_amount = 0
    self.bank_payment_requests.each do |payment_request|
      errors = []
      unless self.processing_status_ids.include?(payment_request.status_id)
        errors << "Payment order cannot be approved in this state"
        self.errors_found = true
      end
      # unless payment_request.controlling_user_id == user.id
      #   errors << "You are not authorized to approve this payment order"
      #   self.errors_found = true
      # end
      unless payment_request.get_reviewers.include? user
        errors << "You are not authorized to approve this payment order"
        self.errors_found = true
      end
      if errors.empty?
        self.processable_amount += payment_request.payment_order.amount_requested&.value
      else
        self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
      end
      self.validate_result << {
          user: payment_request.owner.name,
          name: payment_request.name,
          amount: payment_request.payment_order.amount_requested&.value,
          errors: errors,
          valid: (errors.empty? ? true : false),
          id: payment_request.id,
          payment_request: payment_request,
          created_at: payment_request.created_at.strftime("%d-%m-%Y"),
          payment_mode: payment_request.payment_mode
      }
    end
  end

  def post_process
    # here we will sort the orders according to valid first and then invalid later
    approvable_orders = []
    non_approvable_orders = []
    self.validate_result.each do |order|
      if order[:valid]
        approvable_orders << order
      else
        non_approvable_orders << order
      end
    end
    self.validate_result = approvable_orders + non_approvable_orders
  end

  def success
    params[:errors_found] = self.errors_found,
    params[:validate_result] = self.validate_result
    params[:processable_amount] = self.processable_amount
    params[:unprocessable_amount] = self.unprocessable_amount
    BankTransfer::PaymentRequest::Review::BulkApprove::ApprovePresenter.new(user, params, messages)
  end

end
