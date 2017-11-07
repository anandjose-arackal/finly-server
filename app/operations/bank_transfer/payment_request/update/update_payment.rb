class BankTransfer::PaymentRequest::Update::UpdatePayment < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :payment, :payment_request, :payment_params, :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice, :cgst_amount, :sgst_amount, :igst_amount,
                :discount_amount, :tds_amount, :tax_amount

  def init
    super
    id = params[:payment_id] || params[:payment][:id] # todo - temporary till the front end fixes it
    self.payment = self.payment_order.payments.find_by(id: id)
    self.payment_params = payment_attributes
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment not found"
    end
  end

  def pre_process
    # adding the invoice id so that it gets updated anf not created again
    # if it already exists in the database
    if self.payment.invoice.present? && self.payment_params[:invoice_attributes].present?
      self.payment_params[:invoice_attributes][:id] = self.payment.invoice.id
    end
  end

  def process
    unless self.payment.update(payment_params)
      add_message :error, self.payment.errors.full_messages
    end
    # calculate_tax_and_discounts
  end

  def post_process
    add_message :success, "Payment updated"
  end

  private

  def payment_attributes
    # todo - add attributes here for invoice and attachment
    params.require(:payment).permit(invoice_attributes: [:tax_rate, :gst_type_id, :TDS, :tds_type_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date,
                                                         :invoice_number, :inclusive_of_taxes,
                                                         amount_attributes: [:value, :currency_id]],
                                    invoice_attachment_attributes: [:attached_file, :description],
                                    amount_attributes: [:value, :currency_id]
                                    )
  end

  def calculate_tax_and_discounts
    self.invoice = payment.invoice
    if self.invoice.inclusive_of_taxes # calculate the other amounts retrospectively
      self.net_amount = self.invoice.amount&.value
      # first calculate the gross amount from the
      calculate_inclusive_taxes
      calculate_discount
      calculate_tds
    else # calculate proactively
      self.invoice_amount = self.invoice.amount&.value
      calculate_discount
      calculate_exclusive_taxes
      calculate_tds
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

  def calculate_discount
    if self.invoice.discount.blank?
      self.discount_amount = 0
      self.gross_amount = self.invoice_amount
    end
    case invoice.discount_type_id
      when 1, '1'
        self.discount_amount = (invoice.discount*amount)/100
      when 2, '2'
        self.discount_amount = invoice.discount
      else
        # do nothing?
    end
    self.gross_amount = self.invoice_amount - self.discount_amount
  end

  def calculate_exclusive_taxes
    case self.invoice.gst_type_id
      when 1, '1'
        # i.e. IGST
        self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, (self.invoice.tax_rate), self.invoice.tax_type_id)
      when 2, '2'
        # i.e SGST + CGST
        self.net_amount = TaxCalculationUtils.exclusive_tax_amount(self.gross_amount, 2*(self.invoice.tax_rate), self.invoice.tax_type_id)
      else
        # do nothing?
    end
    self.tax_amount = self.net_amount - self.gross_amount
  end

  def calculate_inclusive_taxes
    case self.invoice.gst_type_id
      when 1, '1'
        # i.e. IGST
        self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.net_amount, (self.invoice.tax_rate), self.invoice.tax_type_id)
      when 2, '2'
        # i.e SGST + CGST
        self.gross_amount = TaxCalculationUtils.inclusive_tax_amount(self.net_amount, 2*(self.invoice.tax_rate), self.invoice.tax_type_id)
      else
        # do nothing?
    end
    self.tax_amount = self.gross_amount - self.net_amount
  end

  def calculate_tds
    original_amount = self.net_amount
    self.net_amount = TaxCalculationUtils.tds_amount(self.net_amount, self.invoice.tds, self.invoice.tds_type_id)
    self.tds_amount = original_amount - self.net_amount
  end

end