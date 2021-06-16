class Docs::PaymentTickets::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :bank_payment_request_auditor, :auditor, :admin
  resolver 'payment_tickets.default'
  reference '{{record.id}}'

  def self.reference(id = nil, args = {})
    {id: '{{record.id}}',
     args: {
            non_po_forms_enabled: "{% if record.non_po_form_enabled == true %}{{true}}{% else %}{{ false }}{% endif %}"}
    }
  end

  # Fixed column is always default true
  column :description, label: 'Description', fixed: true, sort: :name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :payment_ticket_id, sort: :id, label: "Payment Ticket ID", default: true, includes: [:policy, :created_by] do
    text value: :payment_ticket_id, format: "primary"
    text value: 'Policy: {{record.policy.name}}'
    user value: :created_by
  end


  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :updated_at, sort: true do
    date value: :updated_at
  end

  # column :created_by, default: true, includes: [:created_by] do
  #   user value: :created_by
  # end

  column :ticket_type, label: "Ticket Type", default: true do
    text value: :ticket_type
  end

  column :base_currency, label: "Base Currency", active: :is_accessable do
    text value: :base_currency_code
  end

  column :status, default: true, includes: [:status] do
    indicator value: :pt_status, format: :format_status
  end

  column :policy, default: false, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)
  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)

  column :requested, default: true, includes: [payment_order: { amount_requested: :currency }] do
    amount value: -> (context) { context[:exposure].payment_order.amount_requested }
    # , tool_tip: :format_amount_requested_tool_tip
  end

  column :processed, default: true, includes: [payment_order: { amount_processed: :currency }] do
    amount value: -> (context) { context[:exposure].payment_order.amount_processed }
    # , tool_tip: :format_amount_processed_tool_tip
  end

  column :scheduled_date, sort: :payment_order_scheduled_at, default: true, includes: [:payment_order] do
    date value: "{{record.payment_order.scheduled_at}}"
  end

  column :submitted_at, sort: :submitted_at, default: true do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at, default: true do
    date value: :approved_at
  end

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

    collection = collection.joins(:payment_order).unscope(:order)
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group('bank_payment_requests.status_id').count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # Open / Retracted
    counter.add BankPaymentRequestStatus::GROUP_OPEN, 'Open', (
      counts[BankPaymentRequestStatus.id_for(:open)].to_i +
        counts[BankPaymentRequestStatus.id_for(:retracted)].to_i +
        counts[BankPaymentRequestStatus.id_for(:creation_in_progress)].to_i
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add BankPaymentRequestStatus::GROUP_AWAITING_APPROVAL, 'Awaiting Approval',
                  collection.with_status_id(BankPaymentRequestStatus::GROUP_AWAITING_APPROVAL).select(:id).count
    end

    counter.add BankPaymentRequestStatus::GROUP_PROCESSING, "Processing", (
      counts[BankPaymentRequestStatus.id_for(:processing)].to_i +
        counts[BankPaymentRequestStatus.id_for(:submitted)].to_i +
        counts[BankPaymentRequestStatus.id_for(:unapprove)].to_i
    )

    # Approved / Auto Approved
    counter.add BankPaymentRequestStatus::GROUP_PENDING_CREDIT, 'Pending Credit', (
      counts[BankPaymentRequestStatus.id_for(:approved)].to_i +
        counts[BankPaymentRequestStatus.id_for(:auto_approved)].to_i +
        counts[BankPaymentRequestStatus.id_for(:pending)].to_i
    )

    counter.add BankPaymentRequestStatus::GROUP_SCHEDULED, 'Scheduled', collection.with_status_id(BankPaymentRequestStatus::GROUP_SCHEDULED).select(:id).count
    counter.add BankPaymentRequestStatus::GROUP_PARTIALLY_COMPLETED, "Partially Completed", collection.with_status_id(BankPaymentRequestStatus::GROUP_PARTIALLY_COMPLETED).select(:id).count
    counter.add BankPaymentRequestStatus::GROUP_FAILED, 'Failed', collection.with_status_id(BankPaymentRequestStatus::GROUP_FAILED).select(:id).count
    counter.add BankPaymentRequestStatus::GROUP_COMPLETED, 'Completed', collection.with_status_id(BankPaymentRequestStatus::GROUP_COMPLETED).select(:id).count

    [:rejected].each do |status|
      counter.add BankPaymentRequestStatus.id_for(status), status.to_s.titleize, counts[BankPaymentRequestStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:bank_payment_request_reviewer, :admin]
  end

  def self.base_currency_code(context)
    context[:record]&.base_currency&.country_code
  end

  def self.pt_status(context)
    return 'Awaiting Approval' if context[:record].status_id == BankPaymentRequestStatus.id_for(:processing) and context[:record].controlling_user?(context[:user])

    context[:record].status_name(context[:user])&.titleize
  end

  def self.pt_type( context )
    if context[:record].is_domestic
      'Domestic'
    else
      'International'
    end
  end

  def self.format_status(context)
    case context[:record].status_name(context[:user])&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved, :pending, :creation_in_progress, :credited, :pending_credit, :completed
      format = 'success'
    when :processing, :submitted, :unapprove, :awaiting_approval, :scheduled
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

  def self.format_amount_requested_tool_tip(context)
    user = context[:user]
    value = context[:record].payment_order&.amount_requested&.value.to_f
    
    if user.present? && user.non_po_invoice_form_enabled 
      country_code = context[:record].base_currency&.country_code
      "#{country_code} #{value}"
    else
      country_sym = context[:record].base_currency&.symbol
      "#{country_sym} #{value}"
    end
  end

  def self.format_amount_processed_tool_tip(context)
    user = context[:user]
    value = context[:record].payment_order&.amount_processed&.value.to_f

    if user.present? && user.non_po_invoice_form_enabled 
      country_code = context[:record].base_currency&.country_code
      "#{country_code} #{value}"
    else
      country_sym = context[:record].base_currency&.symbol
      "#{country_sym} #{value}"
    end
  end

  def self.is_accessable( user )
    user.present? && user.non_po_invoice_form_enabled 
  end

end