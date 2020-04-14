class Docs::PaymentTickets::Payments::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'payments.default'
  reference '{{record.payment_order.bank_payment_request.id}}'

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

  column :note, default: true do
    text value: :note
  end

  column :utr, label: "Bank Reference Number", default: true, includes: [:reference_resource] do
    text value: :utr
  end

  column :submitted_at, sort: true do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.submitted_at }
  end

  column :approved_at, sort: true do
    date value: -> (context) { context[:record].payment_order.bank_payment_request.approved_at }
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: -> (context) { context[:record].payment_order.scheduled_at }
  end

  column :created_by, default: true, sort: :payment_order_bank_payment_request_created_by_id, includes: [payment_order: {bank_payment_request: :created_by}] do
    user value: -> (context) { context[:record].payment_order.bank_payment_request.created_by }
  end

  column :status, default: true, sort: :payment_status_id, includes: [:status] do
    badge value: "{{record.status.name}}", format: :format_status
  end

  column :policy, sort: :payment_order_bank_payment_request_policy_id, default: true, includes: [payment_order: {bank_payment_request: :policy}] do
    text value: "{{record.payment_order.bank_payment_request.policy.name}}"
  end

  column :payment_amount, default: true, sort: :amount_value, includes: {amount: :currency} do
    amount value: :amount
  end

  # column :progress, label: 'Approval Progress', default: true, includes: [:dlrms] do
  #   progress_bar value: :reviewal_progress
  # end

  # column :controlling_user, default: true, includes: [payment_order: {bank_payment_request: :controlling_user}] do
  #   user value: -> (context) { context[:record].payment_order.bank_payment_request.controlling_user }
  # end

  column :controlling_level, default: true, includes: [payment_order: {bank_payment_request: :controlling_level}] do
    text value: "{{record.payment_order.bank_payment_request.controlling_level.name}}"
  end

  column :initiating_account, includes: [:initiating_account] do
    text value: "{{record.initiating_account_type_name}}"
  end

  column :initiating_user, includes: [:initiating_user] do
    user value: :initiating_user
  end

  column :receiving_account, includes: [:receiving_account, :receiving_user] do
    text value: "{{record.receiving_account_type_name}}"
  end

  column :payment_mode, default: true, sort: true do
    text value: "{{payment_mode | upcase}}"
  end

  column :type, default: true, sort: true do
    text value: :parent_type_name
  end

  column :account, default: true, includes: [:receiving_account] do
    text value: '{{record.receiving_account.account_number}}', format: 'primary'
    text value: 'IFSC: {{record.receiving_account.ifsc | upcase}}'
  end

  column :verified_account, label: "Is Account Verified", includes: [:receiving_account] do
    boolean value: '{{record.receiving_account.verified}}'
  end

  column :empaneled_vendor, label: "Is Vendor Empaneled", includes: [:receiving_user] do
    boolean value: '{{record.vendor.authorized}}'
  end

  column :reverse_charge_vendor, label: "RCM Applicable Vendor", includes: [:receiving_account] do
    boolean value: '{{record.vendor.rcm_enabled}}'
  end

  column :gst_registered, label: "GSTIN Vendor", includes: [:receiving_account] do
    boolean value: '{{record.vendor.gst_registered}}'
  end

  column :vendor_type, label: "Vendor Type", includes: [:receiving_account] do
    text value: '{{record.vendor.vendor_type.name}}'
  end

  column :pan_number, label: "PAN Number", includes: [:receiving_account] do
    text value: '{{record.vendor.pan}}'
  end

  column :msme_registered, label: "MSME Registered Vendor", includes: [:receiving_account] do
    boolean value: '{{record.vendor.msme_registered}}'
  end

  column :msme_registration_number, label: "MSME Registration Number", includes: [:receiving_account] do
    text value: '{{record.vendor.msme_registration_number}}'
  end

  column :vendor_status, includes: [:receiving_account] do
    text value: '{{record.vendor.status.name}}'
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

  column :vendor_location, includes: [:parent] do
    text value: '{{record.vendor_location.name}}'
  end

  column :category, includes: [:parent] do
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

  column :transaction_period_from, includes: [:parent] do
    date value: :transaction_period_from
  end

  column :transaction_period_to, includes: [:parent] do
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
    # (counts[BankPaymentRequestStatus.id_for(:processing)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:submitted)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:unapprove)] || 0)
    # )
    #
    # # Approved / Auto Approved
    # counter.add 93, 'Approved', (
    # (counts[BankPaymentRequestStatus.id_for(:approved)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:auto_approved)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:creation_in_progress)] || 0) +
    #     (counts[BankPaymentRequestStatus.id_for(:pending)] || 0)
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
      # if context[:record].controlling_user_id == context[:user].id
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