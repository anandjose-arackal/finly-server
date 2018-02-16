class BankTransfer::PaymentRequest::Review::BulkCreditValidate < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result

  class BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :result

    def init
      self.result = params[:result]
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
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "No payment orders to process"
      return
    end

    #todo - validation to ensure that only approved payment orders can be credited

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
      unless hash[:allowed]
        errors << "#{payment_request.payment_mode} transfers are outside the bank transfer window for today. You can either change the transfer type to IMPS or proceed and we will schedule the payment for the next transfer window"
        errors << "Next available window for this order starts at: 8:00 AM on #{hash[:next_date].strftime("%d %B, %Y")}"
      end
      unless payment_request.approved?
        errors << "Only approved payment orders can be credited"
        hash[:selectable] = false
      end
      hash[:errors] = errors
      self.result << hash
    end
  end

  def success
    params[:result] = self.result
    BankTransfer::PaymentRequest::Review::BulkCreditValidate::BulkCreditValidationPresenter.new(user, params, messages)
  end

end