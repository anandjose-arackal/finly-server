# this operation takes the data from the front end, passes it to
# the Process operation and formats the data for database persistence
class BankTransfer::PaymentRequest::Create < BankTransfer::PaymentRequest::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account, :request_params,
                :company_id, :bank_payment_request, :requested_amount,
                :unauthorized_vendors_presence, :invoice_parameters,
                :invoice_amount, :payment_amount, :payment,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance_amount,
                :policy_id,
                :account_owner_type,
                :invoice_attachments

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

    # initializing the account owner type to retrieve the right bank account
    case params[:account_owner_type]
      when 1, '1'
        self.account_owner_type = "User"
      when 2, '2'
        self.account_owner_type = "YesBankVendor"
      else
        self.account_owner_type = "YesBankVendor"
    end

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
    self.invoice_attachments = []
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

  def pre_process
    # attaching invoice attachments to the invoices of this payment order if they
    # are passed inside the request
    processed_order_data.each do |order_details|
      invoice_attachment_ids = order_details[:invoice_attachment_ids]
      inv_attachment = user.company.invoice_attachments.find_by(id: invoice_attachment_ids)
      if inv_attachment.present?
        self.invoice_attachments << inv_attachment
      else
        self.invoice_attachments << ""
      end
    end
  end

  def process
    # if the user has enough balance for the transaction themselves, the request will get auto approved
    # and credited to the respective bank accounts
    # this should now create a BankPaymentRequest and save it in the DB
    self.bank_payment_request = BankPaymentRequest.new(request_params)
    validate_custom_fields_invoice(processed_order_data)
    return if has_errors?
    unless bank_payment_request.save
      add_message :error, bank_payment_request.errors.full_messages
      return
    end
    self.bank_payment_request.payment_order.payments.each_with_index do |payment, index|
      payment_params = request_params[:payment_order_attributes][:payments_attributes][index]
      calculate_tax_and_discounts(payment_params, payment)
      if self.invoice_attachments[index].present? && payment.invoice.present?
        inv_attachment = self.invoice_attachments[index]
        inv_attachment.update(invoice_id: payment.invoice.id)
      end
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

    # update the requested amount for this payment order
    self.bank_payment_request.payment_order.update_requested_amount

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
    p[:name] = params[:name]
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
          api_initiated: params[:api_initiated],
          external_reference_id: order_details[:external_reference_id],
          note: order_details[:note],
          category_id: order_details[:category_id],
          department_id: order_details[:department_id],
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
              inclusive_of_taxes: !!order_details[:inclusive_of_taxes],
              category_id: order_details[:category_id],
              cost_center_id: order_details[:cost_center_id],
              tds_slab_id: order_details[:tds_slab_id],
              invoice_type_id: order_details[:invoice_type_id],
              original_amount_attributes: {
                  value: order_details[:original_amount],
                  currency_id: 1
              },
              freight_amount_attributes: {
                  value: order_details[:freight],
                  currency_id: 1
              },
              advance_amount_attributes: {
                  value: order_details[:advance_amount],
                  currency_id: 1
              },
              roundoff_amount: order_details[:roundoff_amount],
              invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
              company_id: user.company_id,
              invoice_items_attributes: invoice_items_attributes
          }
      }
    end
    p
  end

  def invoice_params

  end

  def retrieve_bank_account(order_details)
    if order_details[:account_id].present?
      id = order_details[:account_id]
      ba = BankAccount.find_by(id: id)
      return ba
    else
      ba = BankAccount.non_deleted.find_by(account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                           company_id: self.company_id, name: order_details[:name]&.strip,
                                           account_owner_type: self.account_owner_type)
      vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id)
      ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
      if ba.nil?
        ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                account_owner: vendor, company_id: self.company_id, default_account: true)

      end
      return ba
    end
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