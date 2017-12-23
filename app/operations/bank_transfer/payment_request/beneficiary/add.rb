# This operation takes a bunch of data regarding payments and invoices for a particular payment request
# and adds the respective data for the payment

class BankTransfer::PaymentRequest::Beneficiary::Add < BankTransfer::PaymentRequest::Beneficiary::Base

  attr_accessor :payments_data, :amount, :bank_payment_request, :payment_order,
                :error_messages, :processed_order_data, :order_data, :company_id,
                :unauthorized_vendors_presence,
                :invoice_amount, :payment_amount, :payment,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance_amount, :custom_fields, :policy_id

  def pre_validate
    super
    if params[:payment_order].blank?
      add_message :error, "No bank accounts data passed"
    end
  end

  def init
    super
    self.company_id = self.payment_order.company_id
    self.order_data = params[:payment_order]
    self.policy_id = self.bank_payment_request.policy_id
    op = BankTransfer::PaymentRequest::Process.(user, scheduled_at: params[:scheduled_at],
                                                      payment_order: self.order_data,
                                                      policy_id: self.policy_id)
    self.processed_order_data = op.payment_order_data
    retrieve_payments_data
  end

  def validate
    super
    # checking if the payment data is valid - all or nothing
    valid = true
    self.error_messages = []
    self.payments_data.each do |data|
      payment = self.payment_order.payments.build(data)
      unless payment.valid?
        valid = false
        error_messages << payment.errors.full_messages.to_sentence
      end
    end
    unless valid
      add_message :error, error_messages.to_sentence
    end
  end

  def process
    self.payments_data.each_with_index do |data, index|
      payment = self.payment_order.payments.build(data)
      # set custom field data
      set_custom_fields(false, payment, self.custom_fields[index])
      payment.save
      calculate_tax_and_discounts(payment)
    end
  end

  def post_process
    add_message :success, "Beneficiaries added!"

    # update the amount requested for this particular payment order
    amount_requested = self.payment_order.request_total
    payment_order.amount_requested&.update(value: amount_requested)

    # todo - get back to this
    # if bank_payment_request.retracted? || bank_payment_request.rejected?
    #   # adding comments for all the beneficiaries removed in the comments
    #   params[:payment_order].each do |data|
    #     id = data[:id]
    #     account = user.company.bank_accounts.find_by(id: id)
    #     bank_payment_request.comments.build(action_id: BankPaymentRequestCommentAction.id_for(:add_beneficiary),
    #                                         user_id: user.id,
    #                                         beneficiary_id: account.id).save
    #   end
    # end
  end

  private

  def retrieve_payments_data
    self.payments_data = []
    self.custom_fields = []
    self.processed_order_data.each do |order_details|
      bank_account = retrieve_bank_account order_details
      initiating_account = bank_payment_request.payment_order.initiating_account || user.bank_wallet
      self.custom_fields << order_details[:custom_fields]
      self.payments_data << {
          initiating_account: initiating_account,
          receiving_account: bank_account,
          receiving_user: bank_account.account_owner,
          initiating_user: user,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_type_id: PaymentType.id_for(:credit),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          application: RequestStore.store[:current_app],
          payment_mode: bank_payment_request.payment_order.payment_mode,
          amount_attributes: {
              value: order_details[:original_amount],
              currency_id: 1
          },
          date: (bank_payment_request.payment_order.scheduled_at || DateUtils.local_date),
          invoice_attributes: {
              original_amount_attributes: {
                  value: order_details[:original_amount],
                  currency_id: 1
              },
              freight_amount_attributes: {
                  value: order_details[:freight],
                  currency_id: 1
              },
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
              advance: order_details[:advance]
          }
      }
    end
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
    ba
  end


  def set_custom_fields(save, payment, data)
    fields = data
    return if data.blank?
    custom_fields = {custom_fields: fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
    unless data[:custom_fields].blank?
      data.delete(:custom_fields) # removing the custom fields because payment creation will throw an error
    end
  end

  def calculate_tax_and_discounts(payment)
    self.invoice = payment.invoice
    if payment.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
      self.after_tax_amount = self.invoice.original_amount&.value
      # first calculate the gross amount from the
      calculate_inclusive_taxes
      calculate_tds
      calculate_discount_inclusive
      self.net_amount = self.after_tax_amount - self.tds_amount
      self.invoice_amount = self.gross_amount + self.discount_amount
      calculate_advance_paid
    else # calculate proactively
      self.invoice_amount = self.invoice.original_amount&.value
      calculate_discount_exclusive
      calculate_exclusive_taxes
      calculate_tds
      self.net_amount = self.gross_amount + self.tax_amount - self.tds_amount
      self.invoice_amount = invoice.original_amount&.value
      calculate_advance_paid
    end
    # update the invoice with the respective calculated amounts
    payment.invoice.update(
        amount_attributes: {
            value: self.invoice_amount,
            currency_id: 1,
            id: payment.invoice.amount&.id
        },
        net_amount_attributes: {
            value: self.net_amount,
            currency_id: 1,
            id: payment.invoice.net_amount&.id
        },
        gross_amount_attributes: {
            value: self.gross_amount,
            currency_id: 1,
            id: payment.invoice.gross_amount&.id
        },
        discount_amount_attributes: {
            value: self.discount_amount,
            currency_id: 1,
            id: payment.invoice.discount_amount&.id
        },
        tds_amount_attributes: {
            value: self.tds_amount,
            currency_id: 1,
            id: payment.invoice.tds_amount&.id
        },
        tax_amount_attributes: {
            value: self.tax_amount,
            currency_id: 1,
            id: payment.invoice.tax_amount&.id
        },
        advance_amount_attributes: {
            value: self.advance_amount,
            currency_id: 1,
            id: payment.invoice.advance_amount&.id
        }
    )
    # also update the payment with all the respective amounts
    payment.amount&.update(value: self.net_amount)
  end

  def calculate_discount_exclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_amount
      return
    end
    # because the discount rate will always be known
    self.discount_amount = (invoice.discount*self.invoice_amount)/100
    self.gross_amount = self.invoice_amount - self.discount_amount
  end

  def calculate_discount_inclusive
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.invoice_amount = self.gross_amount
      return
    end
    # because the discount is also always shown
    self.invoice_amount = (self.gross_amount*100)/(100 - invoice.discount)
    self.discount_amount = self.invoice_amount - self.gross_amount
  end

  def calculate_exclusive_taxes
    if self.invoice.tax.blank?
      self.net_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax))
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes
    if self.invoice.tax.blank?
      self.after_tax_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.after_tax_amount, (self.invoice.tax))
    self.tax_amount = self.after_tax_amount - self.gross_amount
  end

  def calculate_tds
    new_gross_amount = TaxCalculationUtils.tds_amount(self.gross_amount, self.invoice.tds)
    self.tds_amount = self.gross_amount - new_gross_amount
  end

  def calculate_advance_paid
    if self.invoice.advance.blank?
      # no change in net amount
      self.advance_amount = 0
      return
    end
    original_net_amount = self.net_amount
    self.advance_amount = (self.invoice.advance*self.net_amount)/100
    self.net_amount = original_net_amount - self.advance_amount
  end

end
