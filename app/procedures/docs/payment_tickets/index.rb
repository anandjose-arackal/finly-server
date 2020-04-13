class Docs::PaymentTickets::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'payment_tickets.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :description, label: 'Description', fixed: true, sort: :name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :payment_ticket_id, sort: :id, label: "PO Number", default: true do
    text value: :payment_ticket_id, format: "primary"
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :submitted_at, sort: :submitted_at, default: true do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at, default: true do
    date value: :approved_at
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: "{{record.payment_order.scheduled_at}}"
  end

  column :status, default: true, includes: [:status] do
    badge value: :pt_status, format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :requested, default: true, includes: [payment_order: {amount_requested: :currency}] do
    amount value: "{{record.payment_order.amount_requested}}"
  end

  column :processed, default: true, includes: [payment_order: {amount_processed: :currency}] do
    amount value: "{{record.payment_order.amount_requested}}"
  end

  column :progress, label: 'Approval Progress', default: true, includes: [:dlrms] do
    progress_bar value: :reviewal_progress
  end

  column :controlling_user, default: true, includes: [:controlling_user] do
    user value: :controlling_user
  end

  column :controlling_level, default: true, includes: [:controlling_level] do
    text value: "{{record.controlling_level.name}}"
  end

  column :payment_mode, includes: [:payment_order] do
    text value: :payment_mode
  end

  counter -> (user, collection) do
    # 90 :open,  :retracted
    # 91 :awaiting_approval
    # 92 :submitted, :processing, :unapprove
    # 93 :approved, :pending, :creation_in_progress, :auto_approved
    # :rejected,
    # :credited

    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_ids
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # Open / Retracted
    counter.add 90, 'Open', (counts[BankPaymentRequestStatus.id_for(:open)] + counts[BankPaymentRequestStatus.id_for(:retracted)])

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  collection.where(status_id: BankPaymentRequestStatus.id_for(:processing), controlling_user_id: user.id).count
    end

    counter.add 92, "Processing", (
        (counts[BankPaymentRequestStatus.id_for(:processing)] || 0) +
        (counts[BankPaymentRequestStatus.id_for(:submitted)] || 0) +
        (counts[BankPaymentRequestStatus.id_for(:unapprove)] || 0)
    )

    # Approved / Auto Approved
    counter.add 93, 'Approved', (
        (counts[BankPaymentRequestStatus.id_for(:approved)] || 0) +
        (counts[BankPaymentRequestStatus.id_for(:auto_approved)] || 0) +
        (counts[BankPaymentRequestStatus.id_for(:creation_in_progress)] || 0) +
        (counts[BankPaymentRequestStatus.id_for(:pending)] || 0)
    )

    [:rejected, :credited].each do |status|
      counter.add BankPaymentRequestStatus.id_for(status), status.to_s.titleize, counts[BankPaymentRequestStatus.id_for(status)]
    end

    counter
  end

  def self.awaiting_approval_roles
    [:bank_payment_request_reviewer, :admin]
  end

  def self.pt_status(user, record, record_exposure)
    return 'Awaiting Approval'.upcase if record.status_id == BankPaymentRequestStatus.id_for(:processing) and record.controlling_user_id == user.id

    record.status&.name&.humanize&.upcase
  end

  def self.format_status(user, record, record_exposure)
    case record.status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved, :pending, :creation_in_progress, :credited
      format = 'success'
    when :processing, :submitted, :unapprove
      if record.controlling_user_id == user.id
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted
      format = 'info'
    else
      format = 'danger'
    end
    format
  end
end