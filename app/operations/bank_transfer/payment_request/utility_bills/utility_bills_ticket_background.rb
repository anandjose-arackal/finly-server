class BankTransfer::PaymentRequest::UtilityBills::UtilityBillsTicketBackground < BackgroundOperation

  sidekiq_options queue: :payments_queue

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
                :company_id, :execute, :payment_params, :bbps_bills, :company,
                :transfer_mode_id, :transfer_mode, :ticket_type, :logger, :log_data

  def self.call(user, options = {})
    self.new.perform(user, options)
  end

  def perform(user, options, request_store_hash = nil)
    self.logger = LogStashLogger.new(type: :file, path: 'log/logstash_payments_creation.log', sync: true)
    self.log_data = {}
    self.log_data[:start_time] = DateTime.now.utc
    self.log_data[:klass_name] = self.class.name
    self.log_data[:job] = "payments_creation"
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.bank_payment_request = BankPaymentRequest.find_by(id: options[:bank_payment_request_id])
    self.log_data[:bank_payment_request_id] = self.bank_payment_request&.id
    self.payments_attributes = options[:payments_attributes]
    self.log_data[:number_of_payments] = self.payments_attributes.count
    self.ticket_type = options[:ticket_type]
    self.bbps_bills = BbpsBill.where(id: options[:bbps_bill_ids])
    self.options = options
    self.run
  end

  def initialize

  end

  def pre_validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment order not found"
    end
  end

  def init
    self.company_id = self.bank_payment_request.owner.company_id
    self.user = self.bank_payment_request.owner
    self.company = self.user.company
    self.log_data[:company_name] = self.bank_payment_request.owner.company.name
    self.log_data[:company_id] = self.company_id
    self.payment_mode = self.bank_payment_request.payment_mode
    self.transfer_mode_id = self.bank_payment_request.transfer_mode_id
    # here assign attributes to the existing bank payment request object which can be saved later
    self.payment_params = []
    self.payments_attributes.each do |payment|
      initiating_account = company.utility_bills_account
      receiving_account = BbpsBiller.find_by(id: payment[:account_id])
      self.payment_params << {
          payment_type_id: PaymentType.id_for(:credit),
          application: "vp",
          receiving_user_type: payment[:receiving_user_type],
          receiving_user_id: payment[:receiving_user_id],
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: initiating_account.class.name,
          initiating_account_id: initiating_account.id,
          receiving_account_type: receiving_account.class.name,
          receiving_account_id: receiving_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: payment[:payment_purpose_id],
          purchase_order_id: payment[:purchase_order_id],
          payment_mode: self.payment_mode,
          transfer_mode_id: self.transfer_mode_id,
          reference_resource_type: "BbpsYesBankTransaction",
          amount_attributes: {
              value: payment[:requested_amount],
              currency_id: Currency.first.id
          },
          note: payment[:note],
          date: DateUtils.local_date,
          department_id: payment[:department_id],
          category_id: payment[:category_id],
          company_id: user.company_id,
          cost_center_id: payment[:cost_center_id],
          api_initiated: true,
          parent_type: payment[:parent_type],
          parent_id: payment[:parent_id]
      }
    end
  end

  def validate

  end

  def process
    self.payment_params.each do |payment_param|
      payment_param[:payment_order_id] = self.bank_payment_request.payment_order.id
      payment = ::Payment.new(payment_param)
      # payment = self.bank_payment_request.payment_order.payments.build(payment_param)
      if payment.save
        puts "Utility SUCCESSFUL", payment.id
      else
        puts "ERROR", payment.errors.full_messages
      end
    end

    # if flag
    # now once the payment request has been created and the payments saved, we can mark it as open
    max_payment_amount = self.bank_payment_request.payment_order.payments.reload.joins(:amount).pluck(:value).max || 0
    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open), max_payment_amount: max_payment_amount)
    self.bank_payment_request.payment_order.reload.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))

    puts 'SUCCESSFUL!'
    # end

    self.log_data[:end_time] = DateTime.now.utc
    self.logger.info(self.log_data)
  end

  private

end