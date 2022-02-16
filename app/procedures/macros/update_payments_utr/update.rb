class Macros::UpdatePaymentsUtr::Update < Transactions::API

  attr_accessor :payment

  schema do
    params do
      required(:macro_id).filled
      required(:macro_job_id).filled
      required(:payments_utr).filled
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
    context[:payments_utr_date] = params[:payments_utr]
    context[:company_id] = params[:company_id]
  end

  def validate(context, params:, current_user:, record_class:, **)
    if context[:payments_utr_date].empty?
      context[:error] = "payments data must not blank"
      return true
    end
  end

  def process(context, params:, current_user:, record_class:, **)
    result = []
    context[:payments_utr_date].each do |payments_data|
      if payments_data[:payment_id].present?
        self.payment = record_class.find(payments_data[:payment_id])
      else
        next
      end
      if self.payment.present?
        self.payment.update(utr: payments_data[:utr])  
        self.payment.update(processed_at: payments_data[:processed_date]) 
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
      else
        result.push(data) << payments_data[:payment_id]
      end
    end
    context[:result] = result
    true
  end

  end
