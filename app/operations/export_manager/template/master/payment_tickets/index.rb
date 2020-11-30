require 'ostruct'
class ExportManager::Template::Master::PaymentTickets::Index < ExportManager::Builders::Template

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
end