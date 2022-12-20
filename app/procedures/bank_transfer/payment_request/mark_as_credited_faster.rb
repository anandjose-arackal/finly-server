class BankTransfer::PaymentRequest::MarkAsCreditedFaster < Transactions::API
  
  step :pre_validate
  step :init 
  step :validate
  step :process
  
  def pre_validate(options, params:, current_user:, **)
    if params[:password].blank?
      add_message options, :error, :base, 'You need to provide your password to initiate the transfer'
      return false
    end
    unless current_user.valid_password?(params[:password])
      add_message options, :error, :base, 'Invalid Password'
      return false
    end
    true
  end

  def init(options, params:,current_user:, **)
    ids = params[:id] || params[:ids] || params[:bank_payment_request_ids] || params[:bank_payment_request_id]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    options[:bank_payment_requests] = BankTransfer::PaymentRequest::Index.(current_user, params).payment_requests.with_id(ids) rescue nil
    true
  end

  def validate(options, params:, bank_payment_requests:, **)
    if bank_payment_requests.blank? || bank_payment_requests.empty?
      add_message options, :error, :base, "Payment orders not found"
      return false
    end
    bank_payment_requests.each do |payment_request|
      if payment_request.open? || payment_request.retracted? || payment_request.rejected? || payment_request.credited?
        add_message options, :error, :base, "Payment Order: #{payment_request.name} cannot be marked as Credited as it is #{payment_request.status.name.humanize}"
        return false
      end

      case payment_request.payments.first.class.name
      when 'Invoice'
        payments = payment_request.payments.joins(:invoice).where(invoices: {invoice_status_id: InwardInvoiceStatus.id_for(:voided)})
        if payments.present?
          add_message options, :error, :base, "Payments with IDs #{payments.pluck(:id).join(", ")} have invoices which are voided. Please remove them before marking the Ticket as credited."
          return false
        end
      end
    end
   true
  end

  def process(options, params:, bank_payment_requests:, current_user:, **)
    add_message options, :success, :base, "Marked as credited initiated, please check back in some time"
    bank_payment_requests.each do |payment_request|

      parameters = {
        document: payment_request,
        aasm_event: 'mark_as_credited',
      }

      op = WorkflowManager::Base.(current_user, parameters)

      if op.success?
        BankTransfer::PaymentRequest::MarkAsCreditedBackground.call_async(payment_request: payment_request, current_user: current_user)
      else
        add_message options, :error, :base, op.messages[:error]
        return false
      end
    end
    true
  end
  
end
