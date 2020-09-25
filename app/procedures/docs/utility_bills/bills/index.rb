class Docs::UtilityBills::Bills::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions *Docs::UtilityBills::Subscriptions::Index.permissions
  resolver 'utility_bills.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :biller, fixed: true, sort: :subscription_name, includes: [subscription: :biller], default: true do
    text value: '{{record.subscription.biller.biller_name}}', format: 'primary'
    text value: '{{record.subscription.name}}'
  end

  column :bill_id, label: "Bill ID", sort: :sequence_id, default: true do
    text value: :bill_id, format: 'primary'
  end

  column :subscription_details, default: true, includes: [:subscription] do
    text value: :customer_param_value_1
    text value: :customer_param_value_2
    text value: :customer_param_value_3
  end

  column :subscription_id, label: "Subscription ID", default: true, includes: [:subscription] do
    text value: "{{record.subscription.subscription_id}}"
  end

  column :biller_category, sort: :subscription_biller_category_name, includes: [subscription: :biller], default: true do
    text value: '{{record.subscription.biller.biller_category_name}}'
  end

  column :category, sort: :subscription_biller_category_name, includes: [subscription: :category], default: true do
    text value: '{{record.subscription.category.name}}'
    text value: ->(context) {"Ledger: #{context[:record].subscription.category.gl_code}" if context[:record]&.subscription&.category&.gl_code.present?}
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :status, default: true, includes: [:status] do
    indicator value: :bbps_bill_status, format: :format_status
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

  column :utr, label: "UTR", default: true, includes: [:payments] do
    text value: ->(context) {context[:record].payments&.first&.bbps_bank_transaction&.bbps_ref_id}
  end

  column :tax_rate, sort: :tax_rate_value, default: true, includes: [:tax_rate] do
    text value: "{{record.tax_rate.display_name}}"
  end

  column :payment_status, label: "Payment Status", default: true, includes: [:payments] do
    indicator value: ->(context) {context[:record].payments&.first&.payment_status&.to_exposure&.name || 'Pending'}, format: :format_payment_status
  end

  column :created_at do
    date value: :created_at
  end

  column :updated_at do
    date value: :updated_at
  end

  column :submitted_at, default: true, sort: :submitted_at do
    date value: :submitted_at
  end

  column :approved_at, default: true, sort: :approved_at do
    date value: :approved_at
  end

  column :amount, default: true, includes: [total_amount: :currency] do
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

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

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
        (counts[BbpsBillStatus.id_for(:open)].to_i) +
        (counts[BbpsBillStatus.id_for(:retracted)].to_i)
    )

    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval', collection.with_status_id(91).awaiting_action_items(user.id).count
    end

    # Processing
    counter.add BbpsBillStatus.id_for(:awaiting_approval), "Processing", counts[BbpsBillStatus.id_for(:awaiting_approval)].to_i

    # Pending Payment - approved/auto_approved/partiallycustom_param_key_1_paid/unpaid/initiated
    counter.add 92, 'Pending Payment', (
        counts[BbpsBillStatus.id_for(:approved)].to_i +
        counts[BbpsBillStatus.id_for(:auto_approved)].to_i +
        counts[BbpsBillStatus.id_for(:payment_ticket_created)].to_i +
        counts[BbpsBillStatus.id_for(:payment_initiated)].to_i +
        counts[BbpsBillStatus.id_for(:payment_ticket_deleted)].to_i
    )

    [:rejected, :paid, :voided, :expired].each do |status|
      counter.add BbpsBillStatus.id_for(status), status.to_s.titleize, counts[BbpsBillStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:utility_bill_reviewer]
  end

  def self.bbps_bill_status(context)
    return 'Processing'.titleize if context[:record].status_id == BbpsBillStatus.id_for(:awaiting_approval) and not context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
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

  def self.format_payment_status(context)
    case context[:record].payments&.first&.payment_status&.name&.to_s&.to_sym
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
      format = 'info'
    end
    format
  end

  def self.customer_param_value_1(context)
    return " " if context[:record].subscription.customer_param_value_1.blank?

    "#{context[:record].subscription.customer_param_key_1}: #{context[:record].subscription.customer_param_value_1}"
  end

  def self.customer_param_value_2(context)
    return " " if context[:record].subscription.customer_param_value_2.blank?

    "#{context[:record].subscription.customer_param_key_2}: #{context[:record].subscription.customer_param_value_2}"
  end

  def self.customer_param_value_3(context)
    return ' ' if context[:record].subscription.customer_param_value_3.blank?

    "#{context[:record].subscription.customer_param_key_3}: #{context[:record].subscription.customer_param_value_3}"
  end

end