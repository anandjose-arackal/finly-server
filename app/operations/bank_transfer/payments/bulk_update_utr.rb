class BankTransfer::Payments::BulkUpdateUtr < BankTransfer::Payments::Base

  attr_accessor :company_id, :payments_data, :result_array, :admin_user, :bank_payment_requests, :all_payments, :update_payments, :new_transactions, 
                :existing_transactions,:all_transactions, :bank_transaction_class,
                :payments, :result, :payments_data_process
                  
  def pre_validate
    add_message :error, "Invalid parameters, please try again" if params.blank?
  end

  def init
    self.payments_data =  permitted_params[:payments_utr]
    self.company_id = params[:company_id]
    self.result_array = []
    # ids=[]
    # payments_data.each do |payment_object|
    #   ids << PaymentOrder.find(Payment.find(payment_object[:payment_id]).payment_order_id).bank_payment_request.id
    # end
    # unless ids.is_a?(Array)
    #   ids = ids.split(",")
    # end
    # Company.find(company_id).users.each do |user|
    #   if user.admin?
    #     self.admin_user = user
    #     break
    #   end
    # end
    # self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(admin_user, params).payment_requests.with_id(ids) rescue nil
    self.bank_transaction_class = Company.find(self.company_id).feature_subscription.bank_transaction_class
  end

  def validate
    # if self.payments_data.empty?
    #   add_message :error, "payments data is empty"
    # end
    # if self.bank_payment_requests.blank? || self.bank_payment_requests.empty?
    #   add_message :error, "Payment orders not found"
    #   return
    # end
    # bank_payment_requests.each do |payment_request|
    #   if payment_request.open? || payment_request.retracted? || payment_request.rejected? || payment_request.credited?
    #     add_message :error, "Payment Order: #{payment_request.name} cannot be marked as Credited as it is #{payment_request.status.name.humanize}"
    #   end

    #   case payment_request.payments.first.class.name
    #   when 'Invoice'
    #     payments = payment_request.payments.joins(:invoice).where(invoices: {invoice_status_id: InwardInvoiceStatus.id_for(:voided)})
    #     if payments.present?
    #       add_message :error, "Payments with IDs #{payments.pluck(:id).join(", ")} have invoices which are voided. Please remove them before marking the Ticket as credited."
    #       # return
    #     end
    #   end
    # end
    # return if has_errors?
  end

  def pre_process
    payment_order_ids = Company.find(self.company_id).payment_orders.with_purpose_id(PaymentPurpose.ids_for(:vendor_payment, :advance_against_purchase_order, :utility_bill_payment)).pluck(:id)
    self.all_payments = Payment.with_payment_order_id(payment_order_ids).to_a

    # self.bank_payment_requests.each do |payment_request|
    #   parameters = {
    #     document: payment_request,
    #     aasm_event: 'mark_as_credited',
    #   }
    #   op = WorkflowManager::Base.(admin_user, parameters)
    #   if op.success?
    #     payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
    #     payment_request.payment_order.payments.each do |payment|
    #       payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    #       update_agreement_beneficiary(payment)
    #       update_agreement_security_deposit(payment)
    #     end
    #     payments = payment_request.payment_order.payments
    #     payments.each do |payment|
    #       invoice = payment.invoice
    #       if invoice.present?
    #         invoice.update_invoice_status
    #       end
    #     end
    #   else
    #     add_message :error, op.messages[:error]
    #   end
    # end
  

  # self.bank_payment_requests.each do |payment_request|
  #   new_amount = payment_request.payment_order.payments.completed.joins(:amount).sum(:value)
  #   payment_request.payment_order.assign_attributes({amount_processed_attributes: {value: new_amount, currency_id: ( payment_request&.get_base_currency&.id rescue 1) }})
  #   payment_request.comments.new user_id: admin_user.id,
  #                                   action_id: BankPaymentRequestCommentAction.id_for(:mark_as_credited)
  #   payment_request.save
  #   # Event::EBankPaymentRequest::Credit.(admin_user, bank_payment_request: payment_request)
  # end
  end

  def process
    self.new_transactions = []
    self.existing_transactions = []
    self.payments = []
    file_payments = []
    self.payments_data_process =  permitted_params[:payments_utr]
    payments_data_process.each do |payment_data|
      self.result_array << payment_data
      id = payment_data[:payment_id]
      utr = payment_data[:utr]
      # begin
        # credited_at = nil
        # credited_at = DateTime.strptime(payment_data[:processed_date], "%m/%d/%Y") if payment_data[:processed_date].present?
        # credited_at += Time.now&.seconds_since_midnight&.seconds unless credited_at.nil?
        # self.result_array.last[-1] = credited_at&.strftime("%m/%d/%Y")
      # rescue ArgumentError => e
      #   self.result_array << "Invalid Processed Date for #{id}"
      #   next
      # end
      
      payment = self.all_payments.find { |payment| payment if payment.id.to_i == id.to_i }
      if payment.blank?
        self.result_array << "This payment(#{id}) was not found."
        next
      end
      unless payment.completed? || payment.failed?
        self.result_array << "Only completed or failed payments can have an attached UTR, failed payment id #{id}"
        next
      end
      if payment.reference_resources.present? && payment.utr.present?
        self.result_array << "This payment(#{id}) already has an associated UTR"
        next
      end

      if payment.reference_resources.present? && payment.receiving_account_type == "BankAccount"
        reference_resource = payment.reference_resources.first
        if reference_resource&.class&.column_names&.include?("bank_reference_number")
          reference_resource.bank_reference_number = utr
        else
          reference_resource.utr = utr
        end
        payment.utr  = utr
        payments << payment
        existing_transactions << reference_resource
      else
        amount = Amount.create(value: payment.amount_value, currency_id: 1)
        if bank_transaction_class&.column_names&.include?("bank_reference_number")
          new_transactions << bank_transaction_class.new(transfer_type: payment.payment_mode,
                                                        bank_reference_number: utr,
                                                        company_id: self.company_id,
                                                        transfer_status_id: BankTransferStatus.id_for(:completed),
                                                        bank_transaction_type_id: BankTransactionType.id_for(:outside_finly),
                                                        beneficiary_bank_account_id: payment.receiving_account&.id,
                                                        reference_payment_id: payment.id,
                                                        amount_id: amount.id,
                                                        created_at: "2022-01-22")
          end
        payment.utr  = utr
        payments << payment
      end
      file_payments << payments
    end
    update_details
    file_payments.each do |payment|
      update_payment_status(payment)
    end
  end

  def post_process
    add_message :success, "Payment request marked as credited"
    add_message :success, "Check the logs for the payments update"
  end

  def success
    params[:result_array]= result_array
    BankTransfer::Payments::BulkUpdateUtr::Presenter.new(admin_user, params, messages)
  end

  class BankTransfer::Payments::BulkUpdateUtr::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :result_array

    def init
      self.result_array = params[:result_array]
    end
  end
 

  private

  def update_payment_status(payment)
    if payment[0].failed?
      payment[0].update(payment_status_id: PaymentStatus.id_for(:completed))
      payment[0].system_messages.destroy_all
      payment[0].system_messages.create(
        system_message_type_id: SystemMessageType.id_for(:success), 
        content: "Updated to completed via utr upload by #{Admin User}."
      )

      payment_order = payment[0].payment_order
      payments_status_ids = payment_order.payments.pluck(:payment_status_id).uniq
      if payments_status_ids.include?(PaymentStatus.id_for(:failed)) && payments_status_ids.include?(PaymentStatus.id_for(:completed))
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      else payments_status_ids.length == 1  && payments_status_ids.include?(PaymentStatus.id_for(:completed) )
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
      end
      byebug
    end
  end

  def update_details
    if bank_transaction_class&.column_names&.include?("bank_reference_number")
      exec_statement self.existing_transactions, true, [:bank_reference_number]
    else
      exec_statement self.existing_transactions, true, [:utr]
    end
    exec_statement self.new_transactions
    exec_statement self.payments, true, [:utr]
  end

  def exec_statement(batch, update=false, keys=[])
    if batch.blank?
      puts "Batch is empty."
      return
    end

    begin
      runner batch, update, keys
      true
    rescue => e
      puts "Error importing the bulk. Reason #{e.message}"
      false
    end
  end

  def runner(batch, update=false, keys)
    klass = batch.first.class
    if update
      klass.import batch, on_duplicate_key_update: keys, validate: false
    else
      klass.import batch, validate: false
    end
  end

  def update_agreement_beneficiary(payment)
    if payment.parent_type == "BeneficiaryPayment" && payment.parent.payment_agreement_id.present?
      unless payment.parent.status_id == BeneficiaryPaymentStatus.id_for(:paid)
        payment.parent.update(status_id: BeneficiaryPaymentStatus.id_for(:paid))
      end
    end
  end

  def update_agreement_security_deposit(payment)
    if payment.parent_type == "SecurityDeposit" && payment.parent.payment_agreement_id.present?
      unless payment.parent.status_id == SecurityDepositStatus.id_for(:paid)
        payment.parent.update(status_id: SecurityDepositStatus.id_for(:paid))
      end
    end
  end
end

private

def permitted_params 
  params.permit(
    payments_utr: [
    :payment_id,
    :utr,
    :processed_date
  ]
)
end