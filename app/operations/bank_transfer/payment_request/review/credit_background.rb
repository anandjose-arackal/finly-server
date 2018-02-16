class BankTransfer::PaymentRequest::Review::CreditBackground < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :options, :initiating_user

  def self.call(payment_request_ids, options = {})
    self.new.perform(payment_request_ids, options)
  end

  def perform(payment_request_ids, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_requests = BankPaymentRequest.where(id: payment_request_ids)
    self.options = options
    self.run
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate

  end

  def init

  end

  def validate
    # todo - validations for the background process that will credit these payment orders

  end

  def process
    self.payment_requests.each do |payment_request|
      op = BankTransfer::YesBank::Create.(user, bank_payment_request: payment_request)
      if op.success?
        # update the bank_payment_request to credited
        payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited), controlling_user: nil, controlling_user_role_id: nil,
                                    controlling_for_user_id: nil, controlling_for_user_role_id: nil)
        # create a trail to show that the BPR was credited
        payment_request.bank_payment_request_trails.create action_user: user,
                                                                action_user_role_id: self.view_role,
                                                                action_id: BankPaymentRequestTrailAction.id_for(:credit),
                                                                modified_user_id: nil,
                                                                modified_user_role_id: nil
      else
        add_message :error, op.messages[:error]
        payment_request.update(status_id: BankPaymentRequestStatus.id_for(:failed))
        return
      end
    end
  end
end