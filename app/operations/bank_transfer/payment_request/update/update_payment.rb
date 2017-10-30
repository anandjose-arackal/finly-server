class BankTransfer::PaymentRequest::Update::UpdatePayment < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :payment, :payment_request

  def init
    super
    id = params[:payment_id]
    self.payment = self.payment_order.payments.find_by(id: id)
  end

  def validate

  end

  def process

  end

  private

  def payment_attributes
    # todo - add attributes here for invoice and attachment
    params.require(:payment).permit(:SGST, :CGST, :IGST, :tax_type_id, :discount, :date,
                                    :discount_type_id, :due_date, :invoice_number,
                                    invoice_attributes: [], address_attributes: [])
  end

end
