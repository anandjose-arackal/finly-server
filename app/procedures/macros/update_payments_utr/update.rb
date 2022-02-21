class Macros::UpdatePaymentsUtr::Update < Transactions::API

  attr_accessor :payment

  schema do
    params do
      required(:payment_utr_date) do
        hash do
          required(:payment_id).filled
          required(:utr).filled
          required(:processed_date).filled
        end
      end
    end
  end
 
  step :pre_validate
  step :init
  step :validate
  step :process

  def pre_validate(context, params:, current_user:, record_class:, **)
    if current_user.blank? || params.blank?
      context[:error] = "user must not blank"
      return true
    end
    true
  end

  def init(context, params:, current_user:, record_class:, **)
    context[:payments_data] = params[:payment_utr_date]
  end

  def validate(context, payments_data:, current_user:, record_class:, **)
    if payments_data.empty?
      context[:error] = "payments data must not blank"
      return true
    end
  end

  def process(context, payments_data:, current_user:, record_class:, **)
    self.payment = record_class.find(payments_data[:payment_id])
    if self.payment.present? && (self.payment.completed? || self.payment.failed?)
      self.payment =  payments_data[:utr]
      self.payment =  payments_data[:processed_date]
      if self.payment.save
        update_invoice_payment_status
      else
        context[:error] = "#{payments_data[:payment_id]} - This payment utr and processed_date not updated because #{self.payment.errors.full_messages}"
      end
    end
    true
  end

  def update_invoice_payment_status
    if self.payment.parent_type == "Invoice"
      if self.payment&.invoice.present?
        self.payment&.invoice&.update_invoice_status
      end
    elsif payment.parent_type == "BbpsBill"
      invoice.parent.update(status_id: BbpsBillStatus.id_for(:paid))
    end
    self.payment.payment_order.update_order_status
    self.payment.payment_order.update_processed_amount
    self.payment.system_messages.destroy_all
  end

end
