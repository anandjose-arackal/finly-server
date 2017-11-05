class BankTransfer::PaymentRequest::Update::UpdatePayment < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :payment, :payment_request, :payment_params, :amount, :gross_amount, :net_amount,
                :invoice, :cgst_amount, :sgst_amount, :igst_amount, :discount_amount, :tds_amount

  def init
    super
    id = params[:payment_id]
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
    params.require(:payment).permit(invoice_attributes: [:SGST, :CGST, :IGST, :gst_type_id, :TDS, :tds_type_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date,
                                                         :invoice_number, :inclusive_of_taxes,
                                                         amount_attributes: [:value, :currency_id],
                                                         gross_amount_attributes: [:value, :currency_id],
                                                         net_amount_attributes: [:value, :currency_id]],
                                    invoice_attachment_attributes: [:attached_file, :description],
                                    amount_attributes: [:value, :currency_id]
                                    )
  end

  def calculate_tax_and_discounts
    self.invoice = payment.invoice
    self.amount = self.invoice.amount&.value
    if self.invoice.inclusive_of_taxes
      # calculate the other amounts retrospectively
      calculate_discount
      calculate_inclusive_taxes
      calculate_tds
    else
      # calculate proactively
      calculate_discount
      calculate_exclusive_taxes
      calculate_tds
    end
    self.invoice.update(
       amount_attributes: {
           value: self.amount,
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
           id: self.invoice.gross_amount&.id
       },
       tds_amount_attributes: {
           value: self.tds_amount,
           currency_id: 1,
           id: self.invoice.gross_amount&.id
       },
       cgst_amount_attributes: {
           value: self.cgst_amount,
           currency_id: 1,
           id: self.invoice.gross_amount&.id
       },
       sgst_amount_attributes: {
           value: self.sgst_amount,
           currency_id: 1,
           id: self.invoice.gross_amount&.id
       },
       igst_amount_attributes: {
           value: self.igst_amount,
           currency_id: 1,
           id: self.invoice.gross_amount&.id
       }
    )
  end

  def calculate_discount
    if invoice.discount.present?
      self.gross_amount = 0
    else
      self.gross_amount = amount
      return
    end
    case invoice.discount_type_id
      when 1, '1'
        self.gross_amount = amount - (invoice.discount*amount)/100
      when 2, '2'
        self.gross_amount = amount - invoice.discount
      else
        # do nothing?
    end
  end

  def calculate_exclusive_taxes
    # because the starting point is the gross amount
    amount = self.gross_amount
    case invoice.gst_type_id
      when '1', 1
        case invoice.tax_type_id
          # 1 - percentage
          when '1', 1
            self.net_amount = amount - ((invoice.SGST)*amount)/100 - ((invoice.CGST)*amount)/100
            return
          # 2 - absolute
          when '2', 2
            self.net_amount = amount - invoice.SGST - invoice.CGST
            return
          else
            # do nothing?
        end
      when 2, '2'
        case invoice.tax_type_id
          # 1 - percentage
          when '1', 1
            self.net_amount = amount - ((invoice.IGST)*amount)/100
            return
          # 2 - absolute
          when '2', 2
            self.net_amount = amount - invoice.IGST
            return
          else
            # do nothing?
        end
      else
        # do nothing?
    end
  end

  def calculate_inclusive_taxes

  end

  def calculate_tds

  end

end
