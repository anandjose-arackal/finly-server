class BankTransfer::PaymentRequest::Payment::Update < BankTransfer::PaymentRequest::Payment::Base

  attr_accessor :payment, :payment_request, :payment_params, :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance, :advance_amount, :payment_order

  def init
    super
    id = params[:payment_id] || params[:payment][:id]
    self.payment = self.payment_order.payments.find_by(id: id)
    self.payment_params = payment_attributes
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment not found"
    end
    # validate custom fields
    if payment.invoice.present?
      set_fields = set_custom_fields(false)
      unless set_fields&.success?
        add_message :error, set_fields&.messages&.dig(:error)
        return
      end
      valid = CustomField::Validate.(self.payment.invoice)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end

    # validate that the amount is being passed
    unless payment_params&.dig(:invoice_attributes, :original_amount_attributes, :value).present?
      add_message :error, "Sub Total cannot be blank"
    end

    # if the amount is inclusive of taxes, the tax cannot be blank
    if StringUtils.to_bool(payment_params&.dig(:invoice_attributes, :inclusive_of_taxes))
      if payment_params&.dig(:invoice_attributes, :tax).blank?
        add_message :error, "When sub total is inclusive of taxes, tax rate cannot be blank"
      end
    end
  end

  def pre_process
    # adding the invoice id so that it gets updated and not created again
    # if it already exists in the database
    if self.payment.invoice.present? && self.payment_params[:invoice_attributes].present?
      self.payment_params[:invoice_attributes][:id] = self.payment.invoice.id
    end

    # adding id for original_amount and freight_amount so that new copies aren't created every time
    if payment_params&.dig(:invoice_attributes, :original_amount_attributes).present?
      payment_params[:invoice_attributes][:original_amount_attributes][:id] = self.payment&.invoice&.original_amount&.id
    end
    if payment_params&.dig(:invoice_attributes, :freight_amount_attributes).present?
      payment_params[:invoice_attributes][:freight_amount_attributes][:id] = self.payment&.invoice&.freight_amount&.id
    end

    if self.payment_params&.dig(:invoice_attributes, :invoice_attachments_attributes)
      # only if the actual attached file is present, do you even make it save
      if self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:attached_file].present?
        if self.payment.invoice&.invoice_attachments.present?
          self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:id] = self.payment.invoice.invoice_attachments.first&.id
        end
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
      elsif self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:remove_file] == '1'
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:_destroy] = true
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:id] = self.payment.invoice.invoice_attachments.first&.id
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
      else
        if self.payment.invoice&.invoice_attachments.present?
          self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
        else
          self.payment_params[:invoice_attributes].delete(:invoice_attachments_attributes)
        end
      end
    end

    # todo - temporary
    self.payment_params[:invoice_attributes][:freight_amount_attributes][:currency_id] = 1
    ##################
  end

  def process
    payment.assign_attributes(payment_params)
    if payment.invoice.present?
      calculate_tax_and_discounts
    end
    set_custom_fields(false) # this should hopefully add the attributes to the model
    unless self.payment.save
      add_message :error, self.payment.errors.full_messages
    end
  end

  def post_process
    self.payment_order.update_requested_amount
    add_message :success, "Payment updated"
  end

  private

  def payment_attributes
    params.require(:payment).permit(:note,
                                    invoice_attributes: [:tax, :gst_type_id, :tds, :tds_type_id, :category_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date,
                                                         :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id,
                                                         original_amount_attributes: [:value, :currency_id],
                                                         freight_amount_attributes: [:value, :currency_id],
                                                         invoice_attachments_attributes: [:attached_file, :description, :remove_file]],
                                    amount_attributes: [:value, :currency_id]
    )
  end

  def set_custom_fields(save)
    fields = params[:custom_fields]
    if fields.blank?
      return
    end
    custom_fields = {custom_fields: fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

  def calculate_tax_and_discounts
    self.payment_params = InvoiceCalculationUtils.calculate_tax_and_discounts(self.payment, self.payment_params)
    return
    # self.invoice = payment.invoice
    # if self.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
    #   self.after_tax_amount = self.invoice.original_amount&.value
    #   # first calculate the gross amount from the
    #   calculate_inclusive_taxes
    #   calculate_tds
    #   calculate_discount_inclusive
    #   self.net_amount = self.after_tax_amount - self.tds_amount
    #   self.invoice_amount = self.gross_amount + self.discount_amount
    #   calculate_advance_paid
    # else # calculate proactively
    #   self.invoice_amount = self.invoice.original_amount&.value
    #   calculate_discount_exclusive
    #   calculate_exclusive_taxes
    #   calculate_tds
    #   self.net_amount = self.gross_amount + self.tax_amount - self.tds_amount
    #   self.invoice_amount = invoice.original_amount&.value
    #   calculate_advance_paid
    # end
    # # assign the respective calculated parameters to the payment params
    # self.payment_params[:invoice_attributes][:amount_attributes] = {
    #     value: self.invoice_amount,
    #     currency_id: 1,
    #     id: self.invoice&.amount&.id
    # }
    # self.payment_params[:invoice_attributes][:net_amount_attributes] = {
    #     value: self.net_amount,
    #     currency_id: 1,
    #     id: self.invoice&.net_amount&.id
    # }
    # self.payment_params[:invoice_attributes][:gross_amount_attributes] = {
    #     value: self.gross_amount,
    #     currency_id: 1,
    #     id: self.invoice.gross_amount&.id
    # }
    # self.payment_params[:invoice_attributes][:discount_amount_attributes] = {
    #     value: self.discount_amount,
    #     currency_id: 1,
    #     id: self.invoice.discount_amount&.id
    # }
    # self.payment_params[:invoice_attributes][:tds_amount_attributes] = {
    #     value: self.tds_amount,
    #     currency_id: 1,
    #     id: self.invoice.tds_amount&.id
    # }
    # self.payment_params[:invoice_attributes][:tax_amount_attributes] = {
    #     value: self.tax_amount,
    #     currency_id: 1,
    #     id: self.invoice.tax_amount&.id
    # }
    # self.payment_params[:invoice_attributes][:advance_amount_attributes] = {
    #     value: self.advance_amount,
    #     currency_id: 1,
    #     id: self.invoice.advance_amount&.id
    # }
    #
    # # adding the payment amount to the params
    # self.payment_params[:amount_attributes] = {
    #     value: self.net_amount,
    #     currency_id: 1,
    #     id: self.payment.amount&.id
    # }
    # # also update the payment with all the respective amounts
    # # self.payment.amount&.update(value: self.net_amount)
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
    self.net_amount = InvoiceCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax))
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes
    if self.invoice.tax.blank?
      self.after_tax_amount = self.gross_amount
      self.tax_amount = 0
      return
    end
    self.gross_amount = InvoiceCalculationUtils.inclusive_tax_amount(self.after_tax_amount, (self.invoice.tax))
    self.tax_amount = self.after_tax_amount - self.gross_amount
  end

  def calculate_tds
    new_gross_amount = InvoiceCalculationUtils.tds_amount(self.gross_amount, self.invoice.tds)
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