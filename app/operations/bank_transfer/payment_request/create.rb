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
        payment_order: self.order_data)
    self.processed_order_data = op.payment_order_data

    # calculating the requested amount here
    self.requested_amount = 0
    processed_order_data.each do |details|
      self.requested_amount += details[:original_amount]&.to_f
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
    unless bank_payment_request.save
      add_message :error, bank_payment_request.errors.full_messages
    end
    self.bank_payment_request.payment_order.payments.each do |payment|
      calculate_tax_and_discounts(payment)
    end
  end

  def post_process
    # if there are unauthorized vendors, mandate an approval flow
    if self.unauthorized_vendors_presence
      bank_payment_request.update(require_approval: true)
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
              original_amount_attributes: {
                  value: order_details[:original_amount],
                  currency_id: 1
              }
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

    self.unauthorized_vendors_presence = false
    if ba.nil?
      ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number], ifsc: order_details[:ifsc],
                              account_owner: vendor, company_id: self.company_id, default_account: true)
      
      # setting unauthorized vendors as true so that after creation, the approval flow is mandated
      self.unauthorized_vendors_presence = true
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

  def calculate_tax_and_discounts(payment)
    self.payment = payment
    self.invoice = payment.invoice
    if self.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
      self.after_tax_amount = self.invoice.original_amount&.value
      # first calculate the gross amount from the
      calculate_inclusive_taxes
      calculate_tds
      calculate_discount_inclusive
      self.net_amount = self.after_tax_amount - self.tds_amount
      self.invoice_amount = self.gross_amount + self.discount_amount
      # calculate_tds
    else # calculate proactively
      self.invoice_amount = self.invoice.original_amount&.value
      calculate_discount_exclusive
      calculate_exclusive_taxes
      calculate_tds
      self.net_amount = self.gross_amount + self.tax_amount - self.tds_amount
      self.invoice_amount = invoice.original_amount&.value
    end
    # update the invoice with the respective calculated amounts
    self.invoice.update(
        amount_attributes: {
            value: self.invoice_amount,
            currency_id: 1,
            id: self.invoice.amount&.id
        },
        net_amount_attributes: {
            value: self.net_amount,
            currency_id: 1,
            id: self.invoice.net_amount&.id
        },
        gross_amount_attributes: {
            value: self.gross_amount,
            currency_id: 1,
            id: self.invoice.gross_amount&.id
        },
        discount_amount_attributes: {
            value: self.discount_amount,
            currency_id: 1,
            id: self.invoice.discount_amount&.id
        },
        tds_amount_attributes: {
            value: self.tds_amount,
            currency_id: 1,
            id: self.invoice.tds_amount&.id
        },
        tax_amount_attributes: {
            value: self.tax_amount,
            currency_id: 1,
            id: self.invoice.tax_amount&.id
        }
    )
    # also update the payment with all the respective amounts
    self.payment.amount&.update(value: self.net_amount)
  end

  def calculate_discount_exclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_amount
      return
    end
    case invoice.discount_type_id
      when 1, '1'
        self.discount_amount = (invoice.discount*self.invoice_amount)/100
      when 2, '2'
        self.discount_amount = invoice.discount
      else
        # do nothing?
    end
    self.gross_amount = self.invoice_amount - self.discount_amount
  end

  def calculate_discount_inclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.invoice_amount = self.gross_amount
      return
    end

    case invoice.discount_type_id
      when 1, '1'
        self.invoice_amount = (self.gross_amount*100)/(100 - invoice.discount)
      when 2, '2'
        self.invoice_amount = self.gross_amount - invoice.discount
      else
        # do nothing?
    end
    self.discount_amount = self.invoice_amount - self.gross_amount
  end

  def calculate_exclusive_taxes
    if self.invoice.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    case self.invoice.gst_type_id
      when 1, '1'
        # i.e. IGST
        self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax), self.invoice.tax_type_id)
      when 2, '2'
        # i.e SGST + CGST
        rate = (self.invoice.tax.blank?) ? 0 : 2*self.invoice.tax
        self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, rate, self.invoice.tax_type_id)
      else
        # do nothing?
    end
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes
    if self.invoice.tax.blank?
      self.after_tax_amount = self.gross_amount
      self.tax_amount = 0
      return
    end

    case self.invoice.gst_type_id
      when 1, '1'
        # i.e. IGST
        self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_tax_amount, (self.invoice.tax), self.invoice.tax_type_id)
      when 2, '2'
        # i.e SGST + CGST
        self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_tax_amount, 2*(self.invoice.tax), self.invoice.tax_type_id)
      else
        # do nothing?
    end
    self.tax_amount = self.after_tax_amount - self.gross_amount

  end

  def calculate_tds
    new_gross_amount = TaxCalculationUtils.tds_amount(self.gross_amount, self.invoice.tds, self.invoice.tds_type_id)
    self.tds_amount = self.gross_amount - new_gross_amount
  end

end

