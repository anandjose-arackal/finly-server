require 'ostruct'
class ExportManager::Master::PaymentTickets::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Payment Ticket Export'
  export_format 'csv'
  resource 'payments'
  subscribe 'payments'
  default true

  attribute :payment_order_id, template: '{{ record.payment_order.bank_payment_request.id }}'
  attribute :payment_order_name, template: '{{ record.payment_order.bank_payment_request.name }}'
  attribute :payment_id, template: '{{ record.id }}'
  attribute :beneficiary_name, template: '{{ record.receiving_account.account_owner.name }}'
  attribute :beneficiary_code, template: '{{ record.vendor.vendor_id }}'
  attribute :beneficiary_account_name, template: '{{ record.receiving_account.name }}'
  attribute :beneficiary_account_number, template: '{{ record.receiving_account.account_number }}'
  attribute :beneficiary_ifsc, template: '{{ record.receiving_account.ifsc }}'
  attribute :payment_mode, template: '{{ record.payment_mode | upcase }}'
  attribute :initiated_by, template: '{{ record.initiating_user.name }}'
  attribute :initiator_email, template: '{{ record.initiating_user.email }}'
  attribute :payment_order_status, template: '{{ record.payment_order.bank_payment_request.status.name }}'
  attribute :payment_order_schedule_date, template: "{{ record.payment_order.scheduled_at | date: '%d-%b-%Y' }}"
  attribute :payment_order_submitted_date, template: "{{ record.payment_order.bank_payment_request.submitted_at | date: '%d-%b-%Y' }}"
  attribute :payment_order_processed_date, template: "{{ record.payment_order.processed_at | date: '%d-%b-%Y' }}"
  attribute :awaiting_action_from, template: '{{ record.payment_order.bank_payment_request.get_reviewers_names }}'
  attribute :policy, template: '{{ record.payment_order.bank_payment_request.policy.name }}'
  attribute :po_number, template: '{{ record.po_number }}'
  attribute :invoice_number, template: '{{ record.invoice.invoice_number }}'
  attribute :invoice_due_date, template: "{{ record.invoice.due_date | date: '%d-%b-%Y' }}"
  attribute :invoice_date, template: "{{ record.invoice.date | date: '%d-%b-%Y' }}"
  attribute :invoice_id, template: '{{ record.invoice.invoice_id }}'
  attribute :original_amount, template: '{{ record.gross_amount.value }}'
  attribute :advance_amount, template: '{{ record.advance_paid.value }}'
  attribute :discount, template: '{{ record.discount.value }}'
  # attribute :tax
  attribute :cgst_sgst_amount, template: '{{ record.cgst_amount }}'
  attribute :igst_amount, template: '{{ record.igst_amount }}'
  attribute :tds, template: '{{ record.tds_amount.value }}'
  attribute :net_payable_amount, template: '{{ record.amount.value }}'
  attribute :bank_reference_number, template: '{{ record.utr }}'
  attribute :note, template: '{{ record.note }}'
  attribute :payment_status, template: '{{ record.status.name }}'
  attribute :error_message, template: '{{ record.error_message }}'

  # section :custom_fields do
  #   attribute :custom_fields, dynamic: true
  # end

  # def custom_fields(row, payment)
  #   payment&.invoice&.custom_fields&.includes(:field_configuration)&.each do |custom_field|
  #     row.add(custom_field.field_configuration.field_name, custom_field.string_value)
  #     unless header.list.include?(custom_field.field_configuration.field_name)
  #       self.header.add custom_field.field_configuration.field_name
  #     end
  #   end

  #   payment&.purchase_order&.custom_fields&.includes(:field_configuration)&.each do |custom_field|
  #     row.add(custom_field.field_configuration.field_name, custom_field.string_value)
  #     unless header.list.include?(custom_field.field_configuration.field_name)
  #       self.header.add custom_field.field_configuration.field_name
  #     end
  #   end

  #   # beneficiary_payment = BeneficiaryPayment.find_by(payment&.beneficiary_payment_id)
  #   # beneficiary_payment&.custom_fields&.includes(:field_configuration)&.each do |custom_field|
  #   #   row.add(custom_field.field_configuration.field_name, custom_field.string_value)
  #   # end
  # # end

  # def input
  #   bank_payment_requests = resolve('payment_tickets.default')
  #   Payment.where("`payments`.`payment_order_id` IN (#{bank_payment_requests.select("payment_order_id").to_sql})")
  # end

  # def payment_order_id (payment)
  #   payment&.payment_order&.bank_payment_request&.id
  # end

  # def payment_order_name (payment)
  #   payment&.payment_order&.bank_payment_request&.name
  # end

  # def payment_id (payment)
  #   payment&.id
  # end

  # def beneficiary_name (payment)
  #   payment&.receiving_account&.account_owner&.name.to_s
  # end

  # def beneficiary_code (payment)
  #   vendor = payment&.receiving_user_type == 'YesBankVendor' ? payment.receiving_user : nil
  #   vendor.present? ? vendor.vendor_id : ' '
  # end

  # def beneficiary_account_name (payment)
  #   payment&.receiving_account&.name.to_s
  # end

  # def beneficiary_account_number (payment)
  #   "\t" + (payment&.receiving_account&.account_number).to_s
  # end

  # def beneficiary_ifsc (payment)
  #   payment&.receiving_account&.ifsc
  # end

  # def payment_mode (payment)
  #   payment&.payment_mode&.upcase
  # end

  # def initiated_by (payment)
  #   payment&.initiating_user&.name
  # end

  # def initiator_email (payment)
  #   payment&.initiating_user&.email
  # end

  # def payment_order_status (payment)
  #   payment&.payment_order&.bank_payment_request&.status&.name&.humanize
  # end

  # def payment_order_schedule_date (payment)
  #   payment&.payment_order&.scheduled_at&.strftime("%d-%b-%Y")
  # end

  # def payment_order_submitted_date (payment)
  #   payment&.payment_order&.bank_payment_request&.submitted_at&.strftime("%d-%b-%Y")
  # end

  # def payment_order_processed_date (payment)
  #   payment&.payment_order&.processed_at&.strftime("%d-%b-%Y")
  # end

  # def awaiting_action_from (payment)
  #   payment&.payment_order&.bank_payment_request&.get_reviewers&.map(&:name)&.join(", ")
  # end

  # def policy (payment)
  #   payment&.payment_order&.bank_payment_request&.policy&.name
  # end

  # def po_number (payment)
  #   purchase_order = (payment&.parent_type == 'PurchaseOrder' ? payment.parent : nil)
  #   purchase_order.present? ? purchase_order&.po_number : ''
  # end

  # def invoice_number (payment)
  #   payment&.invoice&.invoice_number
  # end

  # def invoice_due_date (payment)
  #   payment&.invoice&.due_date&.strftime("%d-%b-%Y")
  # end

  # def invoice_date (payment)
  #   payment&.invoice&.date&.strftime("%d-%b-%Y")
  # end

  # def invoice_id (payment)
  #   payment&.invoice&.invoice_id
  # end

  # def original_amount (payment)
  #   payment_type = payment.parent_type
  #   if payment_type.eql?('PurchaseOrder')
  #     precision_value(payment&.purchase_order&.requested_advance_amount&.value)
  #   elsif payment_type.eql?('BeneficiaryPayment')
  #     precision_value(payment&.parent&.original_amount&.value)
  #   elsif payment_type.eql?('Invoice')
  #     precision_value(payment&.parent&.item_amounts_total)
  #   else
  #     original_amount_invoice(payment)
  #   end
  # end

  # def advance_amount (payment)
  #   payment_type = payment.parent_type
  #   if payment_type.eql?('PurchaseOrder')
  #     0.to_f
  #   elsif payment_type.eql?('BeneficiaryPayment')
  #     precision_value(payment&.parent&.advance_amount&.value).to_f
  #   elsif payment_type.eql?('Invoice')
  #     if payment&.parent&.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice)
  #       payment&.parent&.po_adjusted_advance&.value&.to_f
  #     else
  #       payment&.parent&.advance_amount&.value&.to_f
  #     end
  #   else
  #     0.to_f
  #   end
  # end

  # def discount (payment)
  #   payment_type = payment.parent_type
  #   if ['PurchaseOrder', 'BeneficiaryPayment'].include? (payment_type)
  #     0.to_f
  #   elsif payment_type.eql?('Invoice')
  #     precision_value(payment&.parent&.discount_amount&.value)
  #   else
  #     payment&.invoice&.discount_amount&.value.to_f
  #   end
  # end


  # def cgst_sgst_amount(payment)
  #   payment_type = payment.parent_type
  #   if payment_type.eql?('PurchaseOrder')
  #     0.to_f
  #   elsif 'BeneficiaryPayment'.eql?(payment_type)
  #     payment&.invoice&.gst_type_id == GstType.id_for(:cgst_sgst) ? precision_value(payment&.parent&.tax_amount&.value.to_f) : 0.to_f
  #   elsif  'Invoice'.eql?(payment_type)
  #     payment&.parent&.gst_type_id == GstType.id_for(:cgst_sgst) ? precision_value(payment&.parent&.tax_amount&.value.to_f) : 0.to_f
  #   else
  #     0.to_f
  #   #   payment&.invoice&.tax.to_f
  #   end
  # end

  # def igst_amount(payment)
  #   payment_type = payment.parent_type
  #   if payment_type.eql?('PurchaseOrder')
  #     0.to_f
  #   elsif 'BeneficiaryPayment'.eql?(payment_type)
  #     payment&.invoice&.gst_type_id == GstType.id_for(:igst_amount) ? precision_value(payment&.parent&.tax_amount&.value.to_f) : 0.to_f
  #   elsif  'Invoice'.eql?(payment_type)
  #     payment&.parent&.gst_type_id == GstType.id_for(:igst_amount) ? precision_value(payment&.parent&.tax_amount&.value.to_f) : 0.to_f
  #   else
  #     payment&.invoice&.tax.to_f
  #   end
  # end

  # # def tax (payment)
  # #   payment_type = payment.parent_type
  # #   if payment_type.eql?('PurchaseOrder')
  # #     0.to_f
  # #   elsif ['BeneficiaryPayment', 'Invoice'].include?(payment_type)
  # #     precision_value(payment&.parent&.tax_amount&.value.to_f)
  # #   else
  # #     payment&.invoice&.tax.to_f
  # #   end
  # # end

  # def tds (payment)
  #   tds_amount(payment)
  # end

  # def net_payable_amount (payment)
  #   payment&.amount&.value.to_f
  # end

  # def bank_reference_number (payment)
  #   payment&.utr
  # end

  # def note (payment)
  #   payment&.note
  # end

  # def payment_status (payment)
  #   payment&.payment_status&.name&.humanize
  # end

  # def error_message (payment)
  #   payment&.system_messages.pluck(:content)&.to_sentence
  # end

  # def original_amount_invoice(payment)
  #   original_amount = 0.0
  #   if payment.invoice.present?
  #     invoice = payment.invoice
  #     if invoice&.invoice_items.present?
  #       original_amount = (invoice&.amount&.value.to_f)
  #     else
  #       original_amount = (invoice&.original_amount&.value.to_f)
  #     end
  #   else
  #     original_amount = (payment&.amount&.value.to_f)
  #   end
  #   original_amount
  # end

  # def tds_amount(payment)
  #   tds_amount = 0.0
  #   if payment.parent_type == 'PurchaseOrder'
  #     tds_amount = (payment.parent&.advance_tds_amount&.value.to_f)
  #   else
  #     tds_amount = (payment.invoice&.tds_amount&.value.to_f)
  #   end
  #   tds_amount
  # end
end