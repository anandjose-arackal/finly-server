require 'ostruct'
class ExportManager::Master::PaymentTickets::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Payment Ticket Export'
  configurable true
  system :vp
  screen 'payment_ticket.index'
  handle :bank_payment_requests
  validate :input

  attribute :payment_order_id
  attribute :payment_order_name
  attribute :payment_id
  attribute :beneficiary_name
  attribute :beneficiary_code
  attribute :beneficiary_account_name
  attribute :beneficiary_account_number
  attribute :beneficiary_ifsc
  attribute :payment_mode
  attribute :initiated_by
  attribute :initiator_email
  attribute :payment_order_status
  attribute :payment_order_schedule_date
  attribute :payment_order_submitted_date
  attribute :payment_order_processed_date
  attribute :awaiting_action_from
  attribute :policy
  attribute :po_number
  attribute :invoice_number
  attribute :invoice_due_date
  attribute :invoice_date
  attribute :invoice_id
  attribute :original_amount
  attribute :advance_amount
  attribute :discount
  attribute :tax
  attribute :tds
  attribute :net_payable_amount
  attribute :bank_reference_number
  attribute :note
  attribute :payment_status
  attribute :error_message

  def input
    result = ::BankTransfer::PaymentRequest::Index.(user, params)

    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    return [] if result.blank?

    if params[:id].present?
      bank_payment_requests = BankPaymentRequest.with_id(params[:id]).include_for_data_retrieval
    else
      bank_payment_requests = result.payment_requests
    end

    result_payments_ids = []
    bank_payment_requests.each do |payment_request|
      payment_request.payment_order.payments.each do |payment|
        result_payments_ids.push(payment.id)
      end
    end

    payments = Payment.where(id: result_payments_ids)
    payments
  end

  def payment_order_id ( payment )
    payment&.payment_order_id
  end
  
  def payment_order_name ( payment )
    payment&.payment_order&.bank_payment_request&.name
  end
  
  def payment_id ( payment )
    payment&.id
  end
  
  def beneficiary_name ( payment )
    payment&.receiving_account&.account_owner&.name.to_s
  end
  
  def beneficiary_code ( payment )
    vendor = payment&.receiving_user_type == 'YesBankVendor' ? payment.receiving_user : nil
    vendor.present? ? vendor.vendor_id : ' '
  end
  
  def beneficiary_account_name ( payment )
    payment&.receiving_account&.name.to_s
  end
  
  def beneficiary_account_number ( payment )
    payment&.receiving_account&.account_number.to_s
  end
  
  def beneficiary_ifsc ( payment )
    payment&.receiving_account&.ifsc
  end
  
  def payment_mode ( payment )
    payment&.payment_mode&.upcase
  end
  
  def initiated_by ( payment )
    payment&.initiating_user&.name
  end
  
  def initiator_email ( payment )
    payment&.initiating_user&.email
  end
  
  def payment_order_status ( payment )
    payment&.payment_order&.bank_payment_request&.status&.name&.humanize
  end
  
  def payment_order_schedule_date ( payment )
    payment&.payment_order&.scheduled_at&.strftime("%d-%b-%Y")
  end
  
  def payment_order_submitted_date ( payment )
    payment&.payment_order&.bank_payment_request&.submitted_at&.strftime("%d-%b-%Y")
  end
  
  def payment_order_processed_date ( payment )
    payment&.payment_order&.processed_at&.strftime("%d-%b-%Y")
  end

  def awaiting_action_from ( payment )
    payment&.payment_order.bank_payment_request.get_reviewers&.map(&:name)&.join(", ")
  end
  
  def policy ( payment )
    payment&.payment_order.bank_payment_request.policy&.name
  end
  
  def po_number ( payment )
    purchase_order = (payment&.parent_type == 'PurchaseOrder' ? payment.parent : nil)
    purchase_order.present? ? purchase_order&.po_number : ''
  end
  
  def invoice_number ( payment )
    payment&.invoice&.invoice_number
  end
  
  def invoice_due_date ( payment )
    payment&.invoice&.due_date&.strftime("%d-%b-%Y")
  end
  
  def invoice_date ( payment )
    payment&.invoice&.date&.strftime("%d-%b-%Y")
  end
  
  def invoice_id ( payment )
    payment&.invoice&.invoice_id
  end

  def original_amount ( payment )
    payment_type = payment.parent_type
    if payment_type.eql?('PurchaseOrder')
      precision_value(payment&.parent&.total_after_tax&.value)
    elsif payment_type.eql?('BeneficiaryPayment')
      payment&.parent&.original_amount&.value || 0.0
    else
      original_amount_invoice(payment)
    end
  end
  
  def advance_amount ( payment )
    payment_type = payment.parent_type
    if payment_type.eql?('PurchaseOrder')
      precision_value(payment&.parent&.advance_amount&.value)
    elsif payment_type.eql?('BeneficiaryPayment')
      payment&.parent&.advance_amount&.value || 0.0
    else
      payment&.invoice&.advance_amount&.value || 0.0
    end
  end
  
  def discount ( payment )
    payment_type = payment.parent_type
    if ['PurchaseOrder', 'BeneficiaryPayment'].include? (payment_type)
      0.0
    else
      payment&.invoice&.discount_amount&.value || 0.0
    end
  end
  
  def tax ( payment )
    payment_type = payment.parent_type
    if payment_type.eql?('PurchaseOrder')
      0.0
    elsif payment_type.eql?('BeneficiaryPayment')
      payment&.parent&.tax_amount&.value || 0
    else
      payment&.invoice&.tax || 0.0
    end
  end
  
  def tds ( payment )
    payment_type = payment.parent_type
    if payment_type.eql?('PurchaseOrder')
      payment&.parent&.advance_tds_slab&.tds || 0.0
    elsif payment_type.eql?('BeneficiaryPayment')
      payment&.parent&.tds_amount&.value || 0
    else
      payment&.invoice&.tds || 0.0
    end
  end
  
  def net_payable_amount ( payment )
    payment&.amount&.value || 0.0
  end

  def bank_reference_number ( payment )
    payment&.utr
  end
  
  def note ( payment )
    payment&.note
  end
  
  def payment_status ( payment )
    payment&.payment_status&.name&.humanize
  end
  
  def error_message ( payment )
    payment&.system_messages.pluck(:content)&.to_sentence
  end

  def original_amount_invoice(payment)
    original_amount = 0.0
    if payment.invoice.present?
      invoice = payment.invoice
      if invoice&.invoice_items.present?
        original_amount = (invoice.amount&.value || 0.0)
      else
        original_amount = (invoice&.original_amount&.value || 0.0)
      end
    else
      original_amount = (payment&.amount&.value || 0.0)
    end
    original_amount
  end

  def tds_amount(payment)
    tds_amount = 0.0
    if payment.parent_type == 'PurchaseOrder'
      tds_amount = (payment.parent.advance_tds_amount&.value || 0.0)
    else
      tds_amount = (payment.invoice&.tds_amount&.value || 0.0)
    end
    tds_amount
  end
end