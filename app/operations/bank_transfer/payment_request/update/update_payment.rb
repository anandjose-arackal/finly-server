class BankTransfer::PaymentRequest::Update::UpdatePayment < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :payment, :payment_request, :payment_params

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
    calculate_tax_and_discounts
  end

  def post_process
    add_message :success, "Payment updated"
  end

  private

  def payment_attributes
    # todo - add attributes here for invoice and attachment
    params.require(:payment).permit(invoice_attributes: [:SGST, :CGST, :IGST, :gst_type_id, :TDS, :tds_type_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date,
                                                         :invoice_number, :inclusive_of_taxes, amount_attributes: [:value, :currency_id]],
                                    invoice_attachment_attributes: [:attached_file, :description]
                                    )
  end

  def calculate_tax_and_discounts
    invoice = payment.invoice
    amount = invoice.amount&.value
    if invoice.inclusive_of_taxes
      # calculate the other amounts retrospectively
    else
      # calculate proactively
    end
  end

end
