class Docs::P2P::PurchaseRequests::Index < IndexBuilder::API

  system_subscription :vp
  feature_subscription :purchase_requisition_system
  permissions :purchase_request_initiator, :purchase_request_reviewer, :purchase_request_auditor, :admin
  resolver 'purchase_requests.default'
  reference '{{record.id}}'
  custom_fields :purchase_request

  # Fixed column is always default true
  column :request, label: 'Name', fixed: true do
    text value: :description, format: 'primary'
  end

  column :request_id, sort: :order_number, label: "Request ID", default: true do
    text value: :request_id, format: 'primary'
  end

  column :created_at, sort: true do
    date value: :created_at
  end

  column :updated_at, sort: true do
    date value: :updated_at
  end

  column :submitted_at, sort: :submitted_at, default: true do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at do
    date value: :approved_at
  end

  column :status, sort: :status_name, default: true, includes: [:status] do
    indicator value: :status, format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :amount, default: true, sort: :total_amount_value, includes: [total_amount: :currency] do
    amount value: :total_amount
  end

  column :cost_center, default: true, includes: [:cost_center] do
    text value: :cost_center_name
  end

  column :department, default: true, includes: [:department] do
    text value: :department_name
  end

  column :created_by, default: true, includes: [:creator] do
    user value: :created_by
  end

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_ids
    counts = collection.group(:purchase_request_status_id).count
    counter.add nil, 'All', counts.values.reduce(0, :+)

    # :draft, :retracted
    counter.add PurchaseRequestStatus::GROUP_OPEN, 'Open', (counts[PurchaseRequestStatus.id_for(:draft)].to_i + counts[PurchaseRequestStatus.id_for(:retracted)].to_i)

    # :awaiting_approval,
    if user.has_permission?(:purchase_request_reviewer)
      counter.add PurchaseRequestStatus::GROUP_AWAITING_APPROVAL, 'Awaiting Approval',
                  PurchaseRequest.awaiting_action_items(user.id).count
    end

    # :processing
    counter.add PurchaseRequestStatus.id_for(:awaiting_approval), 'Processing', counts[PurchaseRequestStatus.id_for(:awaiting_approval)].to_i

    # :approved, :auto_approved, :po_created, :partially_closed, :order_initiated
    counter.add PurchaseRequestStatus::GROUP_APPROVED, 'Approved', (
        counts[PurchaseRequestStatus.id_for(:approved)].to_i +
        counts[PurchaseRequestStatus.id_for(:auto_approved)].to_i +
        counts[PurchaseRequestStatus.id_for(:po_created)].to_i +
        counts[PurchaseRequestStatus.id_for(:partially_closed)].to_i +
        counts[PurchaseRequestStatus.id_for(:order_initiated)].to_i
    )

    # :rejected, :closed, :cancelled,
    [:rejected, :closed, :cancelled].each do |status|
      counter.add PurchaseRequestStatus.id_for(status), status.to_s.titleize, counts[PurchaseRequestStatus.id_for(status)].to_i
    end

    counter
  end

  def self.status(context)
    return "Processing" if context[:record].purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval) and not context[:record].controlling_user?(context[:user])

    context[:record].status&.name&.titleize
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :cancelled
      format = 'danger'
    when :approved, :auto_approved, :closed, :order_initiated, :po_created, :partially_closed
      format = 'success'
    when :awaiting_approval
      # if context[:record].controlling_user?(context[:user])
      #   format = 'warning'
      # else
        format = 'info'
      # end
    when :draft, :retracted
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

  def self.cost_center_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].cost_center&.name
  end

  def self.department_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].department&.name
  end

end