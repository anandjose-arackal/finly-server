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
      calculate_tax_and_discounts(payment, data)
      # set custom field data
      set_custom_fields(false, payment, self.custom_fields[index])
      payment.save
    end
  end

  def post_process
    add_message :success, "Beneficiaries added!"

    # update the amount requested for this particular payment order
    payment_order.update_requested_amount

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
          note: order_details[:note],
          category_id: order_details[:category_id],
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
              advance_amount_attributes: {
                  value: order_details[:advance_amount],
                  currency_id: 1
              },
              invoice_number: order_details[:invoice_number],
              date: order_details[:invoice_date],
              due_date: order_details[:due_date],
              tax_type_id: order_details[:tax_type_id],
              discount_type_id: order_details[:discount_type_id],
              tds_type_id: order_details[:tds_type_id],
              invoice_type_id: order_details[:invoice_type_id],
              gst_type_id: order_details[:gst_type_id],
              discount: order_details[:discount],
              tax: order_details[:tax],
              tds: order_details[:tds],
              advance: order_details[:advance],
              invoice_items_attributes: invoice_items_attributes,
              inclusive_of_taxes: order_details[:inclusive_of_taxes],
              category_id: order_details[:category_id],
              cost_center_id: order_details[:cost_center_id],
              tds_slab_id: order_details[:tds_slab_id],
              receiving_account: bank_account
          }
      }
    end
  end

  def retrieve_bank_account(order_details)
    if order_details[:account_id].present?
      id = order_details[:account_id]
      ba = BankAccount.find_by(id: id)
      return ba
    else
      ba = BankAccount.non_deleted.find_by(account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                           name: order_details[:name]&.strip,
                                           company_id: self.company_id)
      vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id)

      self.unauthorized_vendors_presence = false
      if ba.nil?
        ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                account_owner: vendor, company_id: self.company_id, default_account: true)

        # setting unauthorized vendors as true so that after creation, the approval flow is mandated
        self.unauthorized_vendors_presence = true
      end
      ba
    end
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

  def calculate_tax_and_discounts(payment, payment_params)
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
