class Docs::PaymentTickets::Payments::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor, :admin
  resolver 'payments.default'
  reference '{{record.payment_order.bank_payment_request.id}}'
  includes payment_order: :bank_payment_request
  custom_fields :invoice, :purchase_order,
                includes: [invoice: :custom_fields, purchase_order_parent: :custom_fields],
                path: -> (record) do
                  record.invoice&.custom_fields || record.purchase_order_parent&.custom_fields
                end

  # Fixed column is always default true
  column :vendor, fixed: true, includes: [:receiving_user] do
    text value: '{{record.vendor.business_name}}', format: 'primary'
    text value: '{{record.vendor.trade_name}}'
  end

  column :id, label: 'Payment ID', sort: true do
    text value: "{{record.id}}", format: 'primary'
  end

  column :payment_ticket_id, label: "Payment Ticket ID", sort: true, default: true, includes: [payment_order: :bank_payment_request] do
    text value: "{{record.payment_order.bank_payment_request.id}}"
  end

  column :vendor_id, label: "Vendor ID", includes: [:receiving_user] do
    text value: "{{record.vendor.vendor_id}}"
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :updated_at, sort: :updated_at do
    date value: :updated_at
  end

  column :note, default: true do
    text value: :note
  end

  column :utr, label: "UTR", default: true, includes: [:reference_resource] do
    text value: :utr
  end

  column :submitted_at, sort: :payment_order_bank_payment_request_submitted_at, includes: [payment_order: :bank_payment_request] do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.submitted_at }
  end

  column :approved_at, sort: :payment_order_bank_payment_request_approved_at, includes: [payment_order: :bank_payment_request] do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.approved_at }
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: -> (context) { context[:record].payment_order.scheduled_at }
  end

  column :date, sort: true, default: true do
    date value: :date
  end

  # column :processed_date, sort: :processed_at, default: true do
  #   date value: :processed_at
  # end

  # column :last_retried_on, sort: :last_retried_at, default: true do
  #   date value: :last_retried_at
  # end

  column :created_by, default: true, sort: :payment_order_bank_payment_request_created_by_id, includes: [payment_order: {bank_payment_request: :created_by}] do
    user value: -> (context) { context[:record].payment_order.bank_payment_request.created_by }
  end

  column :status, default: true, sort: :payment_status_id, includes: [:status] do
    indicator value: "{{record.status.name}}", format: :format_status
  end

  column :policy, sort: :payment_order_bank_payment_request_policy_id, default: true, includes: [payment_order: {bank_payment_request: :policy}] do
    text value: "{{record.payment_order.bank_payment_request.policy.name}}"
  end

  column :gross_amount, includes: [
      invoice_parent: {gross_amount: :currency},
      bbps_bill_parent: {amount: :currency},
      beneficiary_payment_parent: {gross_amount: :currency},
      purchase_order_parent: {requested_advance_amount: :currency},
      security_deposit_parent: {original_amount: :currency},
  ] do
    amount value: :gross_amount
  end

  column :discount, includes: [
      invoice_parent: {discount_amount: :currency},
  ] do
    amount value: :discount
  end

  column :cgst_amount, label: 'CGST', includes: [
      invoice_parent: {tax_amount: :currency},
      beneficiary_payment_parent: {tax_amount: :currency},
  ] do
    amount value: :cgst_amount
  end

  column :sgst_amount, label: 'SGST', includes: [
      invoice_parent: {tax_amount: :currency},
      beneficiary_payment_parent: {tax_amount: :currency},
  ] do
    amount value: :sgst_amount
  end

  column :igst, label: 'IGST', includes: [
      invoice_parent: {tax_amount: :currency},
      beneficiary_payment_parent: {tax_amount: :currency},
  ] do
    amount value: :igst_amount
  end

  column :tds_slab, includes: [
      invoice_parent: :tds_slab,
      beneficiary_payment_parent: :tds_slab,
      purchase_order_parent: :advance_tds_slab,
  ] do
    text value: "{{record.tds_slab.name}}"
  end

  column :tds_rate, includes: [
      invoice_parent: :tds_slab,
      beneficiary_payment_parent: :tds_slab,
      purchase_order_parent: :advance_tds_slab,
  ] do
    text value: "{{record.tds_slab.rate}}"
  end

  column :tds_amount, includes: [
      invoice_parent: {tds_amount: :currency},
      beneficiary_payment_parent: {tds_amount: :currency},
      purchase_order_parent: {advance_tds_amount: :currency},
  ] do
    amount value: :tds_amount
  end

  column :freight, includes: [
      invoice_parent: {freight_amount: :currency},
  ] do
    amount value: :freight
  end

  column :net_amount, includes: [
      invoice_parent: {net_amount: :currency},
      bbps_bill_parent: {total_amount: :currency},
      beneficiary_payment_parent: {net_amount: :currency},
      purchase_order_parent: {advance_amount: :currency},
      security_deposit_parent: {original_amount: :currency},
  ] do
    amount value: :net_amount
  end

  column :advance_paid, includes: [
      invoice_parent: {advance_amount: :currency},
      beneficiary_payment_parent: {advance_amount: :currency},
  ] do
    amount value: :advance_paid
  end

  column :balance_payable, includes: [
      invoice_parent: {balance_due: :currency},
      bbps_bill_parent: {total_amount: :currency},
      beneficiary_payment_parent: {payable_amount: :currency},
      purchase_order_parent: {advance_amount: :currency},
      security_deposit_parent: {payable_amount: :currency},
  ] do
    amount value: :balance_payable
  end

  column :payment_amount, default: true, sort: :amount_value, includes: {amount: :currency} do
    amount value: :amount
  end

  column :controlling_user, default: true, includes: [payment_order: {bank_payment_request: [:document_level_reviewer_mappings, :level]}] do
    user value: -> (context) do
      bank_payment_request = context[:record].payment_order.bank_payment_request
      bank_payment_request.get_reviewers.first
    end
    text value: -> (context) do
      bank_payment_request = context[:record].payment_order.bank_payment_request
      count = bank_payment_request.get_reviewer_ids.count
      if count > 2
        "+ #{count} Reviewers"
      else
        # To avoid FE from keeping a dashed (--) placeholder
        " "
      end
    end
  end

  column :controlling_level, default: true, includes: [payment_order: {bank_payment_request: :controlling_level}] do
    text value: "{{record.payment_order.bank_payment_request.controlling_level.name}}"
    text value: -> (context) do
      bank_payment_request = context[:record].payment_order.bank_payment_request
      if bank_payment_request.review_in_progress? and bank_payment_request.controlling_level.present?
        "Level: #{bank_payment_request.controlling_level.level_number}"
      else
        " "
      end
    end
  end

  column :progress, label: 'Approval Progress', default: true, includes: [payment_order: {bank_payment_request: [:document_level_reviewer_mappings]}] do
    progress_bar value: ->(context) {
      bank_payment_request = context[:record].payment_order.bank_payment_request
      bank_payment_request.review_progress || 0
    },
                 completed_count: ->(context) {
                   bank_payment_request = context[:record].payment_order.bank_payment_request
                   bank_payment_request.reviewers_completed_count || 0
                 },
                 total_count: ->(context) {
                   bank_payment_request = context[:record].payment_order.bank_payment_request
                   bank_payment_request.reviewers_count || 0
                 }

  end

  # column :progress, label: 'Approval Progress', default: true, includes: [:dlrms] do
  #   progress_bar value: :review_progress
  # end

  # column :controlling_user, default: true, includes: [payment_order: {bank_payment_request: :controlling_user}] do
  #   user value: -> (context) { context[:record].payment_order.bank_payment_request.controlling_user }
  # end

  # column :controlling_level, default: true, includes: [payment_order: {bank_payment_request: :controlling_level}] do
  #   text value: "{{record.payment_order.bank_payment_request.controlling_level.name}}"
  # end

  # column :initiating_account, includes: [:initiating_account] do
  #   text value: "{{record.initiating_account_type_name}}"
  # end

  column :initiating_account, default: true,
         includes: [
             :initiating_account_virtual_bank_account,
             initiating_account_card: :user,
             initiating_account_user_pocket: :user,
             initiating_account_user_wallet: :user,
             initiating_account_vendor_payment_wallet: :user
         ] do
    text value: '{{record.initiating_account_number | upcase}}', format: 'primary'
    text value: '{{record.initiating_account_code | upcase}} '
  end

  column :initiating_user, includes: [:initiating_user] do
    user value: :initiating_user
  end

  column :payment_mode, default: true, sort: true do
    text value: "{{payment_mode | upcase}}"
  end

  column :type, default: true, sort: true do
    text value: :parent_type_name
  end

  column :beneficiary_account, default: true,
         includes: [
             :receiving_account_bbps_biller,
             :receiving_account_bank_account,
             receiving_account_card: :user,
             receiving_account_user_pocket: :user,
             receiving_account_user_wallet: :user,
             receiving_account_vendor_payment_wallet: :user,
             receiving_account_cash_on_hand: :user
         ] do
    text value: '{{record.receiving_account_number | upcase}}', format: 'primary'
    text value: '{{record.receiving_account_code | upcase}}'
  end

  column :verified_account, label: "Is Account Verified", includes: [:receiving_account_bank_account] do
    checkbox value: '{{record.receiving_account_bank_account.verified}}'
  end

  column :empaneled_vendor, label: "Is Vendor Empaneled", includes: [:receiving_user_vendor] do
    checkbox value: '{{record.receiving_user_vendor.authorized}}'
  end

  column :reverse_charge_vendor, label: "RCM Applicable Vendor", includes: [:receiving_user_vendor] do
    checkbox value: '{{record.receiving_user_vendor.rcm_enabled}}'
  end

  column :gst_registered, label: "GSTIN Vendor", includes: [:receiving_user_vendor] do
    checkbox value: '{{record.receiving_user_vendor.gst_registered}}'
  end

  column :vendor_type, label: "Vendor Type", includes: [:receiving_user_vendor] do
    text value: '{{record.receiving_user_vendor.vendor_type.name}}'
  end

  column :pan_number, label: "PAN Number", includes: [:receiving_user_vendor] do
    text value: '{{record.receiving_user_vendor.pan}}'
  end

  column :msme_registered, label: "MSME Registered Vendor", includes: [:receiving_user_vendor] do
    checkbox value: '{{record.receiving_user_vendor.msme_registered}}'
  end

  column :msme_registration_number, label: "MSME Registration Number", includes: [:receiving_user_vendor] do
    text value: '{{record.receiving_user_vendor.msme_registration_number}}'
  end

  column :vendor_status, includes: [:receiving_user_vendor] do
    text value: '{{record.receiving_user_vendor.status.name}}'
  end

  column :cost_center, includes: {parent: :cost_center} do
    text value: '{{record.cost_center.name}}'
  end

  column :department, includes: {parent: :department} do
    text value: '{{record.department.name}}'
  end

  column :billing_location, includes: {parent: :location} do
    text value: '{{record.billing_location.name}}'
  end

  column :shipping_location,
         includes: [
             invoice_parent: :delivery_location,
             purchase_order_parent: :delivery_location
         ] do
    text value: '{{record.billing_location.name}}'
  end

  column :vendor_location,
         includes: [
             invoice_parent: :vendor_location,
             purchase_order_parent: :vendor_location,
             beneficiary_payment_parent: :vendor_location,
             security_deposit_parent: :vendor_location
         ] do
    text value: '{{record.vendor_location.name}}'
  end

  column :category, includes: [beneficiary_payment_parent: :category] do
    text value: '{{record.category.name}}'
  end

  column :invoice_date, includes: [:parent] do
    date value: :invoice_date
  end

  column :due_date, includes: [:parent] do
    date value: :due_date
  end

  column :due_in_days, includes: [:parent] do
    text value: :due_in_days
  end

  column :transaction_period_from, includes: [:invoice_parent] do
    date value: :transaction_period_from
  end

  column :transaction_period_to, includes: [:invoice_parent] do
    date value: :transaction_period_to
  end


  counter -> (user, collection) do
    # 90 :open,  :retracted
    # 91 :awaiting_approval
    # 92 :submitted, :processing, :unapprove
    # 93 :approved, :pending, :creation_in_progress, :auto_approved
    # :rejected,
    # :credited

    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:payment_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # # Open / Retracted
    # counter.add 90, 'Open', (counts[BankPaymentRequestStatus.id_for(:open)] + counts[BankPaymentRequestStatus.id_for(:retracted)])
    #
    # # Awaiting Approval
    # if user.has_permission?(awaiting_approval_roles)
    #   counter.add 91, 'Awaiting Approval',
    #               collection.where(status_id: BankPaymentRequestStatus.id_for(:processing), controlling_user_id: user.id).count
    # end
    #
    # counter.add 92, "Processing", (
    # (counts[BankPaymentRequestStatus.id_for(:processing)].to_i) +
    #     (counts[BankPaymentRequestStatus.id_for(:submitted)].to_i) +
    #     (counts[BankPaymentRequestStatus.id_for(:unapprove)].to_i)
    # )
    #
    # # Approved / Auto Approved
    # counter.add 93, 'Approved', (
    # (counts[BankPaymentRequestStatus.id_for(:approved)].to_i) +
    #     (counts[BankPaymentRequestStatus.id_for(:auto_approved)].to_i) +
    #     (counts[BankPaymentRequestStatus.id_for(:creation_in_progress)].to_i) +
    #     (counts[BankPaymentRequestStatus.id_for(:pending)].to_i)
    # )
    #
    # [:rejected, :credited].each do |status|
    #   counter.add BankPaymentRequestStatus.id_for(status), status.to_s.titleize, counts[BankPaymentRequestStatus.id_for(status)]
    # end

    counter
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :failed, :cancelled
      format = 'danger'
    when :completed
      format = 'success'
    when :scheduled, :possible_failure, :pending_credit
      # Todo show awaiting approvals
      # if context[:record].controlling_user?(context[:user])
      format = 'warning'
      # else
      #   format = 'info'
      # end
    when :pending, :in_progress, :processing, :pending_approval, :pending_retry, :initiated
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

end