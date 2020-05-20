class Docs::PaymentTickets::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor, :admin
  resolver 'payment_tickets.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :description, label: 'Description', fixed: true, sort: :name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :updated_at, sort: true do
    date value: :updated_at
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: "{{record.payment_order.scheduled_at}}"
  end

  column :payment_ticket_id, sort: :id, label: "Payment Ticket ID", default: true do
    text value: :payment_ticket_id, format: "primary"
  end

  column :status, default: true, includes: [:status] do
    indicator value: :pt_status, format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :requested, default: true, includes: [payment_order: {amount_requested: :currency}] do
    amount value: -> (context) { context[:exposure].payment_order.amount_requested }
  end

  column :processed, default: true, includes: [payment_order: {amount_processed: :currency}] do
    amount value: -> (context) { context[:exposure].payment_order.amount_processed }
  end

  column :submitted_at, sort: :submitted_at, default: true do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at, default: true do
    date value: :approved_at
  end

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  # Avoiding this as this fetches data from payments as well, which would result in N+1 query
  # column :payment_mode, includes: [:payment_order] do
  #   text value: :payment_mode
  # end

  counter -> (user, collection) do
    # 90 :open,  :retracted
    # 91 :awaiting_approval
    # 92 :submitted, :processing, :unapprove
    # 93 :approved, :pending, :creation_in_progress, :auto_approved
    # :rejected,
    # :credited

    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # Open / Retracted
    counter.add 90, 'Open', (
        counts[BankPaymentRequestStatus.id_for(:open)].to_i +
        counts[BankPaymentRequestStatus.id_for(:retracted)].to_i +
            counts[BankPaymentRequestStatus.id_for(:creation_in_progress)].to_i
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  BankPaymentRequest.awaiting_action_items(user.id).count
    end

    counter.add 92, "Processing", (
    counts[BankPaymentRequestStatus.id_for(:processing)].to_i +
        counts[BankPaymentRequestStatus.id_for(:submitted)].to_i +
        counts[BankPaymentRequestStatus.id_for(:unapprove)].to_i
    )

    # Approved / Auto Approved
    counter.add 93, 'Pending Credit', (
    counts[BankPaymentRequestStatus.id_for(:approved)].to_i +
        counts[BankPaymentRequestStatus.id_for(:auto_approved)].to_i +
        counts[BankPaymentRequestStatus.id_for(:pending)].to_i
    )

    [:rejected, :credited].each do |status|
      counter.add BankPaymentRequestStatus.id_for(status), status.to_s.titleize, counts[BankPaymentRequestStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:bank_payment_request_reviewer, :admin]
  end

  def self.pt_status(context)
    return 'Awaiting Approval' if context[:record].status_id == BankPaymentRequestStatus.id_for(:processing) and context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved, :pending, :creation_in_progress, :credited
      format = 'success'
    when :processing, :submitted, :unapprove
      if context[:record].controlling_user?(context[:user])
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