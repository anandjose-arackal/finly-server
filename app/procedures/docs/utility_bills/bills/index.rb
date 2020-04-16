class Docs::UtilityBills::Bills::Index < IndexBuilder::API
  include DynamicAttributes

  resolver 'bbps_bills.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :biller, fixed: true, sort: :subscription_name, includes: [subscription: :biller], default: true do
    text value: '{{record.subscription.name}}', format: 'primary'
    text value: '{{record.subscription.biller.biller_name}}'
  end

  column :sequence_id, sort: :sequence_id, default: true do
    text value: :sequence_id, format: 'primary'
  end

  column :subscription_details, default: true do
    text value: :customer_param_value_1
    text value: :customer_param_value_2
    text value: :customer_param_value_3
  end

  column :category, sort: :subscription_biller_category_name, includes: [:subscription], default: true do
    text value: '{{record.subscription.biller_category_name}}'
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :status, default: true, includes: [:status] do
    badge value: :bbps_bill_status, format: :format_status
  end

  column :bill_number, sort: :bill_number, default: true do
    text value: :bill_number, format: 'primary'
  end

  column :bill_date, default: true do
    date value: :bill_date
  end

  column :due_date, default: true do
    date value: :due_date
  end

  column :due_in_days, sort: :due_date, default: true do
    text value: :due_in_days
  end

  column :paid_at, label: "Paid On", default: true, sort: :paid_at do
    date value: :paid_at
  end

  column :transaction_id, label: "Transaction ID", default: true do
    text value: :transaction_id
  end

  column :created_at do
    date value: :created_at
  end

  column :submitted_at, default: true, sort: :submitted_at do
    date value: :submitted_at
  end

  column :approved_at, default: true, sort: :approved_at do
    date value: :approved_at
  end

  column :total_amount, default: true, includes: [total_amount: :currency] do
    amount value: :total_amount
  end

  column :cost_center, default: true, includes: [:cost_center] do
    text value: "{{record.cost_center.name}}"
  end

  column :department, default: true, includes: [:department] do
    text value: "{{record.department.name}}"
  end

  column :location, default: true, includes: [:location] do
    text value: "{{record.location.name}}"
  end

  column :auto_fetched, default: true do
    checkbox value: :auto_fetched
  end

  # column :controlling_user, default: true, includes: [:controlling_user] do
  #   user value: :controlling_user
  # end

  column :controlling_level, default: true, includes: [:controlling_level] do
    text value: "{{record.controlling_level.name}}"
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :hsn_sac do
    text value: :hsn_sac
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # Open - open/retracted
    counter.add 90, 'Open', (
        (counts[BbpsBillStatus.id_for(:open)] || 0) +
        (counts[BbpsBillStatus.id_for(:retracted)] || 0)
    )

    # Awaiting Approval
    # if user.has_permission?(awaiting_approval_roles)
    #   counter.add 91, 'Awaiting Approval',
    #               collection.where(status_id: BbpsBillStatus.id_for(:awaiting_approval), controlling_user_id: user.id).count
    # end

    # Processing
    counter.add BbpsBillStatus.id_for(:awaiting_approval), "Processing", counts[BbpsBillStatus.id_for(:awaiting_approval)]

    # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    counter.add 92, 'Pending Payment', (
        (counts[BbpsBillStatus.id_for(:approved)] || 0) +
        (counts[BbpsBillStatus.id_for(:auto_approved)] || 0) +
        (counts[BbpsBillStatus.id_for(:payment_ticket_created)] || 0) +
        (counts[BbpsBillStatus.id_for(:payment_initiated)] || 0) +
        (counts[BbpsBillStatus.id_for(:payment_ticket_deleted)] || 0)
    )

    [:rejected, :failed, :paid, :voided].each do |status|
      counter.add BbpsBillStatus.id_for(status), status.to_s.titleize, counts[BbpsBillStatus.id_for(status)]
    end

    counter
  end

  def self.awaiting_approval_roles
    [:utility_bill_reviewer]
  end

  def self.bbps_bill_status(context)
    return 'Processing'.titleize if context[:record].status_id == BbpsBillStatus.id_for(:awaiting_approval) and record.controlling_user_id != user.id

    record.status&.name&.titleize
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :failed
      format = 'danger'
    when :paid, :approved, :auto_approved, :payment_ticket_created, :payment_initiated, :payment_ticket_deleted
      format = 'success'
    when :awaiting_approval
      if context[:record].controlling_user?(context[:user])
        format = 'warning'
      else
        format = 'info'
      end
    when :open, :retracted, :voided
      format = 'info'
      # when :unpaid, :partially_paid
      #   format = 'warning'
    else
      format = 'danger'
    end
    format
  end

  def self.customer_param_value_1(context)
    return nil if context[:record].customer_param_value_1.blank?

    "#{context[:record].customer_param_key_1} - #{context[:record].customer_param_value_1}"
  end

  def self.customer_param_value_2(context)
    return nil if context[:record].customer_param_value_2.blank?

    "#{context[:record].customer_param_key_2} - #{context[:record].customer_param_value_2}"
  end

  def self.customer_param_value_3(context)
    return nil if context[:record].customer_param_value_3.blank?

    "#{context[:record].customer_param_key_3} - #{context[:record].customer_param_value_3}"
  end

end