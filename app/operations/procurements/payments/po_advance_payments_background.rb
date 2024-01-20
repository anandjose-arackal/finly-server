# called when user adds excel sheet or manually adds new payments
# This would create multiple individual payments for payment ticket/bankpaymentrequest in the background

class Procurements::Payments::PoAdvancePaymentsBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
                :company_id, :execute, :payment_params, :purchase_orders, :transfer_mode_id, :logger, :log_data

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
    self.log_data[:company_name] = self.bank_payment_request.owner.company.name
    self.log_data[:company_id] = self.company_id
    self.user = self.bank_payment_request.owner
    self.payment_mode = self.bank_payment_request.payment_mode
    self.transfer_mode_id = self.bank_payment_request.transfer_mode_id
    # here assign attributes to the existing bank payment request object which can be saved later
    self.payment_params = []
    self.payments_attributes.each do |payment|
      initiating_account = retrieve_initiating_account(user.company)
      bank_account = retrieve_bank_account(payment)
      reconstruct_po_advance(payment)
      self.payment_params << {
          payment_type_id: PaymentType.id_for(:credit),
          application: "vp",
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: initiating_account.class&.name,
          initiating_account_id: initiating_account.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          # payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_purpose_id: payment[:payment_purpose_id],
          purchase_order_id: payment[:purchase_order_id],
          invoice_id: payment[:invoice_id],
          payment_mode: self.payment_mode,
          reference_resource_type: self.bank_payment_request&.owner&.company&.feature_subscription&.bank_transaction_class&.name,
          amount_attributes: {
              value: payment[:requested_amount],
              currency_id: Currency.first.id
          },
          note: payment[:note],
          date: DateUtils.local_date,
          external_reference_id: payment[:external_reference_id],
          department_id: payment[:department_id],
          category_id: payment[:category_id],
          company_id: user.company_id,
          cost_center_id: payment[:cost_center_id],
          location_id: payment[:location_id],
          api_initiated: true,
          parent_type: payment[:parent_type],
          parent_id: payment[:parent_id],
          transfer_mode_id: payment[:transfer_mode_id]
      }
    end
    self.purchase_orders = PurchaseOrder.where(id: self.payment_params.pluck(:purchase_order_id))

  end

  def validate

  end

  def process
    self.payment_params.each do |payment_param|
      payment_param[:payment_order_id] = self.bank_payment_request.payment_order.id
      payment = ::Payment.new(payment_param)
      payment = self.bank_payment_request.payment_order.reload.payments.build(payment_param)
      if payment.save
        purchase_order = self.purchase_orders.find(payment_param[:purchase_order_id])
        purchase_order.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:initiated))
        payment.save
      else
        puts "ERROR", payment.errors.full_messages
      end
    end

    # now once the payment request has been created and the payments saved, we can mark it as open
    max_payment_amount = self.bank_payment_request.payment_order.payments.reload.joins(:amount).pluck(:value).max || 0
    
    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open), max_payment_amount: max_payment_amount)
    self.bank_payment_request.payment_order.reload.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))

    puts 'SUCCESSFUL!'

    self.log_data[:end_time] = DateTime.now.utc
    self.logger.info(self.log_data)
  end

  private

  def retrieve_initiating_account(company)
    case company&.feature_subscription&.bank_service_provider
    when "YES"
      initiating_account = user.company.yes_bank_company_account
    when "ICICI"
      initiating_account = user.company.icici_bank_company_account
    when "KOTAK"
      initiating_account = user.company.kotak_bank_company_account
    else
      initiating_account = user.company.yes_bank_company_account
    end
    initiating_account
  end

  def retrieve_bank_account(order_details)
    if order_details[:account_id].present?
      id = order_details[:account_id]
      ba = BankAccount.find_by(id: id)
      return ba
    else
      ba = BankAccount.non_deleted.find_by(account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                           company_id: self.company_id, name: order_details[:name]&.strip,
                                           account_owner_type: YesBankVendor.name) # default for API initiations are 2, because they're always for vendors
      vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id)
      ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
      if ba.nil?
        ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                account_owner: vendor, company_id: self.company_id, default_account: true)

      end
      return ba
    end
  end

  # used when tds slab for advance amount is changed from the pt create page
  def reconstruct_po_advance(payment)
    purchase_order = PurchaseOrder.find_by(id: payment[:parent_id])
    unless payment[:advance_tds_slab_id].blank? || (payment[:advance_tds_slab_id].to_i == self.purchase_order.advance_tds_slab_id)
      purchase_order.advance_tds_slab_id = payment[:advance_tds_slab_id]
      purchase_order.save
      purchase_order.process_line_item_calculation
      purchase_order.save
    end
    payment[:requested_amount] = purchase_order.forms_enabled ? purchase_order.po_advance_amount.to_f : purchase_order.advance_amount&.value
  end
end
