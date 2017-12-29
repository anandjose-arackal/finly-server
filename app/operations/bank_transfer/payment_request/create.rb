# when the data reaches this state, all payments will be valid and passing the respective
# basic presence validations
# this operation should also decide if the payment request can be processed directly from the
# owner's Finly Credits - because if so, it can directly be passed to the payment processor
class BankTransfer::PaymentRequest::Create < BankTransfer::PaymentRequest::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account, :request_params,
                :company_id, :bank_payment_request, :requested_amount,
                :unauthorized_vendors_presence, :invoice_parameters,
                :invoice_amount, :payment_amount, :payment,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance_amount,
                :policy_id

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading request'
      return
    end
  end

  def init
    self.order_data = params[:payment_order]
    op = BankTransfer::PaymentRequest::Process.(user, scheduled_at: params[:scheduled_at],
                                                payment_order: self.order_data,
                                                policy_id: params[:policy_id])
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.processed_order_data = op.payment_order_data

    # calculating the requested amount here
    self.requested_amount = 0
    processed_order_data.each do |details|
      self.requested_amount += details[:total_amount].to_f
    end

    # setting the initiating account based on the type of user creating the
    # request as well as the option chosen by the admin
    self.initiating_account = retrieve_initiating_account
    ##########################################################

    #### setting the bank transfer type from the front end ####
    params[:bank_transfer_type] = params[:transfer_type].upcase
    ###########################################################

    self.scheduled_at = op.scheduled_at
    self.company_id = user.company_id
    self.policy_id = params[:policy_id]
    # below variable will contain the payment_request that holds data about initiating accounts and
    # receiving accounts
    self.request_params = payment_request_params
    self.invoice_parameters = invoice_params
  end

  def validate
    if scheduled_at && scheduled_at < Date.today
      add_message :error, 'Scheduled Date cannot be less than the current date'
      return
    end

    if self.processed_order_data.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end

  end

  def process
    # if the user has enough balance for the transaction themselves, the request will get auto approved
    # and credited to the respective bank accounts
    # this should now create a BankPaymentRequest and save it in the DB
    self.bank_payment_request = BankPaymentRequest.new(request_params)
    validate_custom_fields_invoice(processed_order_data)
    return if has_errors?
    # bank_payment_request.payment_order.payments.each do |payment|
    #   payment_params =
    #   if payment.invoice.present? # && payment.valid?
    #     calculate_tax_and_discounts(payment_params)
    #   end
    # end
    # # assign the new attributes that were calculated using the respective libraries
    # payment.assign_attributes(payment_params)
    unless bank_payment_request.save
      add_message :error, bank_payment_request.errors.full_messages
      return
    end
    self.bank_payment_request.payment_order.payments.each_with_index do |payment, index|
      payment_params = request_params[:payment_order_attributes][:payments_attributes][index]
      calculate_tax_and_discounts(payment_params, payment)
    end
  end

  def post_process
    # if there are unauthorized vendors, mandate an approval flow
    authorized = []
    self.bank_payment_request.payment_order.payments.each do |payment|
      if payment.receiving_user_type ==  "YesBankVendor"
        authorized << payment.receiving_user.authorized
      else
        authorized << false
      end
    end
    if authorized.include?(false) || authorized.include?(nil)
      self.bank_payment_request.update(require_approval: true)
    end
    add_message :success, "Payment Request created successfully!"
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::Create::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::Create::FailurePresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
    end

  end

  class BankTransfer::PaymentRequest::Create::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
    end

  end

  private

  def validate_custom_fields_invoice(order_data)
    if self.bank_payment_request.valid?
      self.bank_payment_request.payment_order.payments.each_with_index do |payment, index|
        set_fields = set_custom_fields_invoice payment, self.processed_order_data[index], false
        unless set_fields.success?
          add_message :error, set_fields.messages[:error]
          return
        end
        valid = CustomField::Validate.(self.bank_payment_request)
        unless valid.success?
          add_message :error, valid.messages[:error]
          return
        end
      end
    end
  end

  def set_custom_fields_invoice(payment, data, save)
    custom_fields = {custom_fields: data[:custom_fields]}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

  def set_custom_fields_invoice_items(payment, data, save)

  end

  def payment_request_params
    p = {}
    p[:owner_id] = user.id
    p[:status_id] = BankPaymentRequestStatus.id_for(:open)
    p[:controlling_user_id] = user.id
    p[:requested_amount_attributes] = {
        value: self.requested_amount,
        currency_id: Currency.first.id
    }
    p[:description] = params[:description]
    p[:beneficiary_type_id] = retrieve_beneficiary_type
    p[:policy_id] = self.policy_id
    p[:payment_order_attributes] = {}
    p[:payment_order_attributes][:initiating_user] = user
    p[:payment_order_attributes][:payment_order_status_id] = PaymentOrderStatus.id_for(:pending_approval)
    p[:payment_order_attributes][:company_id] = self.company_id
    p[:payment_order_attributes][:amount_requested_attributes] = {
        value: self.requested_amount,
        currency_id: Currency.first.id
    }
    p[:payment_order_attributes][:payment_mode] = params[:bank_transfer_type]
    p[:payment_order_attributes][:initiating_account_type] = initiating_account.class.name
    p[:payment_order_attributes][:receiving_account_type] = BankAccount.name
    p[:payment_order_attributes][:payment_purpose_id] = PaymentPurpose.id_for(:vendor_payment)
    p[:payment_order_attributes][:payments_attributes] = []
    p[:payment_order_attributes][:application] = RequestStore.store[:current_app]
    p[:payment_order_attributes][:currency_id] = Currency.first.id
    p[:payment_order_attributes][:scheduled_at] = self.scheduled_at
    processed_order_data.each do |order_details|
      # processing the line items of this particular invoice
      invoice_items_attributes = []
      if order_details&.dig(:invoice_attributes, :invoice_items_attributes).present?
        order_details[:invoice_attributes][:invoice_items_attributes].each do |line_item|
          invoice_items_attributes << {
              tax: line_item[:tax],
              discount: line_item[:discount],
              category_id: line_item[:category_id],
              description: line_item[:description],
              rate: line_item[:rate],
              quantity: line_item[:quantity],
              hsn_sac: line_item[:hsn_sac],
              gst_type_id: line_item[:gst_type_id]
          }
        end
      end

      bank_account = retrieve_bank_account order_details
      p[:payment_order_attributes][:payments_attributes] << {
          payment_type_id: PaymentType.id_for(:credit),
          application: RequestStore.store[:current_app],
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: initiating_account.class.name,
          initiating_account_id: initiating_account.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_mode: params[:bank_transfer_type],
          amount_attributes: {
              value: order_details[:original_amount],
              currency_id: Currency.first.id
          },
          note: order_details[:note],
          date: DateUtils.local_date,
          invoice_attributes: {
              invoice_number: order_details[:invoice_number],
              date: order_details[:invoice_date],
              due_date: order_details[:due_date],
              tax_type_id: order_details[:tax_type_id],
              discount_type_id: order_details[:discount_type_id],
              tds_type_id: order_details[:tds_type_id],
              gst_type_id: order_details[:gst_type_id],
              discount: order_details[:discount],
              tax: order_details[:tax],
              tds: order_details[:tds],
              advance: order_details[:advance],
              original_amount_attributes: {
                  value: order_details[:original_amount],
                  currency_id: 1
              },
              freight_amount_attributes: {
                  value: order_details[:freight],
                  currency_id: 1
              },
              invoice_items_attributes: invoice_items_attributes
          }
      }
    end
    p
  end

  def invoice_params

  end

  def retrieve_bank_account(order_details)
    ba = BankAccount.non_deleted.find_by(account_number: order_details[:bank_account_number],
                             company_id: self.company_id)
    vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id)
    ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
    if ba.nil?
      ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number], ifsc: order_details[:ifsc],
                              account_owner: vendor, company_id: self.company_id, default_account: true)
      
    end
    return ba
  end

  def retrieve_beneficiary_type
    bank_account = retrieve_bank_account processed_order_data.first
    return if bank_account.blank?
    case bank_account&.account_owner&.class&.name
      when "YesBankVendor"
        return 2
      when "User"
        return 1
      else
        # do nothing?
    end
  end

  def calculate_tax_and_discounts(payment_params, payment)
    if payment.invoice.invoice_items.present?
      # if there are, in fact, invoice items, use the invoice items library
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(payment_params, payment)
      payment.save
    else
      # if there are no invoice items, use the invoice library to calculate the amounts
      InvoiceCalculationUtils.new.calculate_tax_and_discounts(payment_params, payment)
      payment.save
    end
  end

end

