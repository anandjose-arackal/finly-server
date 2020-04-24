class Docs::P2P::CreditNotes::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'credit_notes.default'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}'

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :credit_note_id, sort: :sequence_id, default: true do
    text value: :credit_note_id, format: 'primary'
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :status, default: true, includes: [:status] do
    indicator value: :credit_note_status, format: :format_status
  end

  column :credit_note_date, default: true, sort: true do
    date value: :credit_note_date
  end

  column :created_at, sort: true do
    date value: :created_at
  end

  column :updated_at, sort: true do
    date value: :updated_at
  end

  column :submitted_at, sort: true do
    date value: :submitted_at
  end

  column :approved_at, sort: true do
    date value: :approved_at
  end

  column :narration do
    text value: :narration
  end

  column :cost_center, default: true, sort: :cost_center_name, includes: [:cost_center] do
    text value: "{{record.cost_center.name}}"
  end

  column :department, default: true, sort: :cost_center_name, includes: [:department] do
    text value: "{{record.department.name}}"
  end

  # column :vendor_location, default: false, includes: [:gstin_location] do
  #   text value: "{{record.gstin_location.location}}"
  # end

  column :billing_location, default: false, includes: [:billing_location] do
    text value: "{{record.billing_location.name}}"
  end

  column :shipping_location, default: false, includes: [:shipping_location] do
    text value: "{{record.shipping_location.name}}"
  end

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :gross_receivable_amount, default: true, sort: :gross_receivable_amount_value, includes: [gross_receivable_amount: :currency]  do
    amount value: :gross_receivable_amount
  end

  column :tax_amount, includes: [tax_amount: :currency]  do
    amount value: :tax_amount
  end

  column :discount_amount, includes: [discount_amount: :currency]  do
    amount value: :discount_amount
  end

  column :net_receivable_amount, default: true, sort: :net_receivable_amount_value, includes: [net_receivable_amount: :currency]  do
    amount value: :net_receivable_amount
  end

  column :tds_rate, includes: [:tds_rate]  do
    text value: '{{record.tds_rate.rate}}'
  end

  column :tds_amount, includes: [tds_amount: :currency]  do
    amount value: :tds_amount
  end

  column :freight_amount, includes: [freight_amount: :currency]  do
    amount value: :freight_amount
  end

  column :previously_adjusted_amount, includes: [previously_adjusted_amount: :currency]  do
    amount value: :previously_adjusted_amount
  end

  column :net_adjustable_amount, includes: [net_adjustable_amount: :currency]  do
    amount value: :net_adjustable_amount
  end

  # Todo invoice related attributes

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    #
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # Open - open/retracted
    counter.add 90, 'Open', (
        counts[CreditNoteStatus.id_for(:draft)].to_i +
        counts[CreditNoteStatus.id_for(:retracted)].to_i
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval',
                  CreditNote.awaiting_action_items(user).count
    end

    # Processing
    counter.add CreditNoteStatus.id_for(:awaiting_approval), "Processing", counts[CreditNoteStatus.id_for(:processing)].to_i

    # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    counter.add 92, 'Pending Adjustment', (
    counts[CreditNoteStatus.id_for(:approved)].to_i +
        counts[CreditNoteStatus.id_for(:auto_approved)].to_i +
        counts[CreditNoteStatus.id_for(:partially_adjusted)].to_i +
        counts[CreditNoteStatus.id_for(:unadjusted)].to_i
    )

    [:rejected, :adjusted, :voided].each do |status|
      counter.add CreditNoteStatus.id_for(status), status.to_s.titleize, counts[CreditNoteStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:credit_note_reviewer, :admin]
  end

  def self.credit_note_status(context)
    return 'Awaiting Approval' if context[:record].status_id == CreditNoteStatus.id_for(:awaiting_approval) and context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  # def self.cost_center_name(context)
  #   return "Multiple" if context[:exposure].cost_allocation_items
  #
  #   context[:exposure].cost_center&.name
  # end
  #
  # def self.department_name(context)
  #   return "Multiple" if context[:exposure].cost_allocation_items
  #
  #   context[:exposure].department&.name
  # end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved, :partially_adjusted, :adjusted, :unadjusted
      format = 'success'
    when :awaiting_approval
      if context[:record].controlling_user?(context[:user])
        format = 'warning'
      else
        format = 'info'
      end
    when :draft, :retracted, :voided
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

end