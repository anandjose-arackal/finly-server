class Docs::UtilityBills::Subscriptions::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :utility_bill_initiator, :utility_bill_reviewer, :utility_bill_master_initiator, :utility_bill_master_reviewer, :bank_payment_request_initiator, :admin
  resolver 'utility_subscriptions.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :biller, fixed: true, sort: :name, includes: [:biller], default: true do
    text value: '{{record.biller.biller_name}}', format: 'primary'
    text value: '{{record.name}}'
  end

  column :subscription_id, sort: :sequence_id, default: true do
    text value: :subscription_id, format: 'primary'
  end

  column :subscription_details, default: true do
    text value: :customer_param_value_1
    text value: :customer_param_value_2
    text value: :customer_param_value_3
  end

  column :biller_category, sort: :biller_category_name, default: true, includes: [:biller] do
    text value: '{{record.biller.biller_category_name}}'
  end

  column :category, sort: :category_id, default: true, includes: [:category] do
    text value: '{{record.category.name}}'
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :status, default: true, sort: :status_id, includes: [:status] do
    indicator value: :subscription_status, format: :format_status
  end

  column :cost_center, default: true, sort: :cost_center_id, includes: [:cost_center] do
    text value: "{{record.cost_center.name}}"
  end

  column :department, default: true, sort: :department_id, includes: [:department] do
    text value: "{{record.department.name}}"
  end

  column :location, default: true, sort: :location_id, includes: [:location] do
    text value: "{{record.location.name}}"
  end

  column :is_auto_fetched, default: true, sort: :auto_fetchable do
    checkbox value: :auto_fetchable
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

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :hsn_sac, default: true, sort: true do
    text value: :hsn_sac
  end

  column :tax_rate, default: true, sort: true, includes: [:tax_rate] do
    text value: "{{record.tax_rate.display_name}}"
  end

  # column :last_paid_at, default: true, sort: true do
  #   date value: :last_paid_at
  # end

  counter -> (user, collection) do
    collection = collection.non_deleted
    
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # Open - open/retracted
    counter.add 90, 'Open', (
        (counts[BbpsBillerSubscriptionStatus.id_for(:draft)].to_i) +
        (counts[BbpsBillerSubscriptionStatus.id_for(:retracted)].to_i)
    )

    # Awaiting Approval
    if user.has_permission?(awaiting_approval_roles)
      counter.add 91, 'Awaiting Approval', collection.awaiting_action_items(user.id).count
    end

    # Processing
    counter.add BbpsBillerSubscriptionStatus.id_for(:awaiting_approval), "Processing", counts[BbpsBillerSubscriptionStatus.id_for(:awaiting_approval)].to_i

    # Pending Payment - approved/auto_approved/partially_paid/unpaid/initiated
    counter.add 92, 'Approved', (
        counts[BbpsBillerSubscriptionStatus.id_for(:approved)].to_i +
        counts[BbpsBillerSubscriptionStatus.id_for(:auto_approved)].to_i +
        counts[BbpsBillerSubscriptionStatus.id_for(:reactivated)].to_i
    )

    [:deactivated, :rejected].each do |status|
      counter.add BbpsBillerSubscriptionStatus.id_for(status), status.to_s.titleize, counts[BbpsBillerSubscriptionStatus.id_for(status)].to_i
    end

    counter
  end

  def self.awaiting_approval_roles
    [:utility_bill_master_reviewer]
  end

  def self.subscription_status(context)
    return 'Processing'.titleize if context[:record].status_id == BbpsBillerSubscriptionStatus.id_for(:awaiting_approval) and not context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :failed
      format = 'danger'
    when :paid, :approved, :auto_approved, :payment_ticket_created, :payment_initiated, :payment_ticket_deleted, :completed, :reactivated
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
    return " " if context[:record].customer_param_value_1.blank?

    "#{context[:record].customer_param_key_1}: #{context[:record].customer_param_value_1}"
  end

  def self.customer_param_value_2(context)
    return " " if context[:record].customer_param_value_2.blank?

    "#{context[:record].customer_param_key_2}: #{context[:record].customer_param_value_2}"
  end

  def self.customer_param_value_3(context)
    return ' ' if context[:record].customer_param_value_3.blank?

    "#{context[:record].customer_param_key_3}: #{context[:record].customer_param_value_3}"
  end

end