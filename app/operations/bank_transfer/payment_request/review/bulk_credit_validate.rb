class BankTransfer::PaymentRequest::Review::BulkCreditValidate < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result, :processable_amount, :unprocessable_amount, :scheduled_amount

  class BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :result, :processable_amount, :unprocessable_amount, :scheduled_amount

    def init
      self.result = params[:result]
      self.processable_amount = params[:processable_amount]
      self.unprocessable_amount = params[:unprocessable_amount]
      self.scheduled_amount = params[:scheduled_amount]
    end

  end

  def init
    ids = params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.payment_requests = op.payment_requests.with_id(ids)
    else
      add_message :error, op.messages[:error]
    end
    self.result = []
    self.processable_amount = self.unprocessable_amount = self.scheduled_amount = 0
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "No payment orders to process"
      return
    end
  end

  def process
    self.payment_requests.each do |payment_request|
      hash = {
          id: payment_request.id,
          name: payment_request.name,
          payment_request: payment_request,
          allowed: TransferTimingUtils.within_timeframe?(payment_request.payment_order.payment_mode, nil),
          next_date: TransferTimingUtils.next_valid_date(nil, payment_request.payment_order.payment_mode),
          total_amount: payment_request.payment_order.amount_requested&.value,
          created_at: payment_request.created_at.strftime("%d-%m-%Y"),
          selectable: true
      }
      errors = []
      # first check if the payment request has been approved
      if payment_request.approved?
        if hash[:allowed]
          self.processable_amount += payment_request.payment_order.amount_requested&.value
        else
          errors << "#{payment_request.payment_mode} transfers are outside the bank transfer window for today. You can either change the transfer type to IMPS and try again or proceed and we will schedule the payment for the next transfer window"
          errors << "Next available window for this order starts at: 8:00 AM on #{hash[:next_date].strftime("%d %B, %Y")}"
          self.scheduled_amount += payment_request.payment_order.amount_requested&.value
        end
      else
        errors << "Only approved payment orders can be credited"
        hash[:selectable] = false
        self.unprocessable_amount += payment_request.payment_order.amount_requested&.value
      end

      hash[:errors] = errors
      self.result << hash
    end
  end

  def success
    params[:result] = self.result
    params[:processable_amount] = self.processable_amount
    params[:unprocessable_amount] = self.unprocessable_amount
    params[:scheduled_amount] = self.scheduled_amount
    BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter.new(user, params, messages)
  end

end