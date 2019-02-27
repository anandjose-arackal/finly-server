class BankTransfer::PaymentRequest::AddPaymentsBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
                :company_id, :execute, :payment_params

  def self.call(user, options = {})
    self.new.perform(user, options)
  end

  def perform(user, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.bank_payment_request = BankPaymentRequest.find_by(id: options[:bank_payment_request_id])
    self.payments_attributes = options[:payments_attributes]
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
    self.payment_mode = self.bank_payment_request.payment_mode
    # here assign attributes to the existing bank payment request object which can be saved later
    self.payment_params = []
    self.payments_attributes.each do |payment|
      bank_account = retrieve_bank_account(payment)
      self.payment_params << {
          payment_type_id: PaymentType.id_for(:credit),
          application: "vp",
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: YesBankCompanyAccount.name,
          initiating_account_id: user.company.yes_bank_company_account.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          purchase_order_id: payment[:purchase_order_id],
          payment_mode: self.payment_mode,
          amount_attributes: {
              value: payment[:original_amount],
              currency_id: Currency.first.id
          },
          note: payment[:note],
          date: DateUtils.local_date,
          external_reference_id: payment[:external_reference_id],
          department_id: payment[:department_id],
          category_id: payment[:category_id],
          company_id: user.company_id,
          api_initiated: true,
          invoice_attributes: {
              category_id: payment[:category_id],
              cost_center_id: payment[:cost_center_id],
              inclusive_of_taxes: payment[:inclusive_of_taxes],
              gst_type_id: payment[:gst_type_id],
              tds_slab_id: payment[:tds_slab_id],
              invoice_number: payment[:invoice_number],
              date: payment[:invoice_date],
              due_date: payment[:due_date],
              tax: payment[:tax],
              discount: payment[:discount],
              invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
              company_id: self.user.company_id,
              receiving_account_type: "BankAccount",
              receiving_account_id: bank_account.id,
              original_amount_attributes: {
                  value: payment[:original_amount],
                  currency_id: 1
              }
          },
          custom_fields: payment[:custom_fields]
      }
    end
  end

  def validate

  end

  def process
    self.payment_params.each do |params|
      custom_fields = params[:custom_fields]
      params.delete(:custom_fields)
      params[:payment_order_id] = self.bank_payment_request.payment_order.id
      payment = ::Payment.new(params)
      # payment = self.bank_payment_request.payment_order.payments.build(params)
      if payment.save
        # perform the required calculations
        InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, payment)
        payment.save
        # now save the custom fields to the invoice
        set_custom_fields_invoice(payment, {custom_fields: custom_fields}, true)
      end
    end

    # now once the payment request has been created and the payments saved, we can mark it as open
    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open))
    self.bank_payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))

    # Create Document Level Reviewer Mapping
    # For setting level specific reviewers from reviewal chain for a document
        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, {reviewal_document: self.bank_payment_request.reload})
    # puts 'SUCCESSFUL!'
  end

  private

  def set_custom_fields_invoice(payment, data, save)
    custom_fields = {custom_fields: data[:custom_fields]}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
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
end