# called when user adds excel sheet or manually adds new payments
# This would create multiple individual payments for payment ticket/bankpaymentrequest in the background

class BankTransfer::PaymentRequest::BeneficiaryPaymentsBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
                :company_id, :execute, :payment_params, :beneficiary_payments

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
      beneficiary_payment = retrieve_beneficiary_payment(payment, bank_account)
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
          cost_center_id: payment[:cost_center_id],
          company_id: user.company_id,
          api_initiated: true,
          beneficiary_payment_id: beneficiary_payment.id,
          parent_type: beneficiary_payment.class.name,
          parent_id: beneficiary_payment.id
          # invoice_attributes: {
          #     category_id: payment[:category_id],
          #     cost_center_id: payment[:cost_center_id],
          #     inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
          #     gst_type_id: payment[:gst_type_id],
          #     tds_slab_id: payment[:tds_slab_id],
          #     # 
          #     # BENEFICIARY PAYMENTS WOULD NO LONGER REQUIRE INVOICES
          #     # 
          #     # invoice_number: payment[:invoice_number],
          #     # date: payment[:invoice_date],
          #     # due_date: payment[:due_date],
          #     tax: payment[:tax],
          #     discount: payment[:discount],
          #     invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
          #     invoice_type_id: InwardInvoiceType.id_for(:beneficiary),
          #     company_id: self.user.company_id,
          #     original_amount_attributes: {
          #         value: payment[:original_amount],
          #         currency_id: 1
          #     },
          #     advance_amount_attributes: {
          #       value: payment[:advance_amount],
          #       currency_id: 1
          #     }
          # },
          # custom_fields: payment[:custom_fields]
      }
    end

    self.beneficiary_payments = BeneficiaryPayment.where(id: self.payment_params.pluck(:beneficiary_payment_id))
  end

  def validate

  end

  def process
    self.payment_params.each do |params|
      custom_fields = params[:custom_fields]
      params.delete(:custom_fields)
      params[:payment_order_id] = self.bank_payment_request.payment_order.id
      # payment = ::Payment.new(params)
      payment = self.bank_payment_request.payment_order.payments.build(params)
      if payment.save
        # perform the required calculations
        beneficiary_payment = self.beneficiary_payments.find(params[:beneficiary_payment_id])
        beneficiary_payment.update(status_id: BeneficiaryPaymentStatus.id_for(:unpaid))

        # InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, payment)
      end
    end

    # now once the payment request has been created and the payments saved, we can mark it as open
    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open))
    self.bank_payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))
    # puts 'SUCCESSFUL!'
  end

  private

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
        ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,account_owner: vendor, company_id: self.company_id, default_account: true)

      end
      return ba
    end
  end

  def retrieve_beneficiary_payment(payment, bank_account)
    # bp = BeneficiaryPayment.create(name:)
    vendor_id = bank_account.account_owner_id
    bank_account_id = bank_account.id
    # bp = BeneficiaryPayment.where('vendor_id LIKE ? OR bank_account_id LIKE ?', vendor_id, bank_account_id )
    
    # bp = BeneficiaryPayment.find_by(vendor_id: vendor_id, bank_account_id: bank_account_id )
    # if bp.present?
    #   return bp
    # else
    #   bp_params = beneficiary_payment_params(payment, vendor_id, bank_account_id)
    #   bp = BeneficiaryPayment.new(bp_params)
    #   bp.calculate_tax_and_amount
    #   bp.save
    #   return bp
    # end
    
    bp_params = beneficiary_payment_params(payment, vendor_id, bank_account_id)
    bp = BeneficiaryPayment.new(bp_params)
    bp.calculate_tax_and_amount
    bp.save
    return bp
  end

  def beneficiary_payment_params(payment, vendor_id, bank_account_id)
    {
      name: payment[:name],
      vendor_id: vendor_id,
      bank_account_id: bank_account_id,
      category_id: payment[:category_id],
      cost_center_id: payment[:cost_center_id],
      department_id: payment[:department_id],
      sub_department_id: payment[:sub_department_id],
      company_id: self.company_id,
      gst_type_id: payment[:gst_type_id],
      tds_slab_id: payment[:tds_slab_id],
      status_id: BeneficiaryPaymentStatus.id_for(:pending),
      inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
      tax: payment[:tax],
      original_amount_attributes: {
              value: payment[:original_amount],
              currency_id: Currency.first.id
      }
    }
  end
end