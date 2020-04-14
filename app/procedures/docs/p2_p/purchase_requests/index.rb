class Docs::P2P::PurchaseRequests::Index < IndexBuilder::API

  resolver 'purchase_requests.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :request, label: 'Name', fixed: true do
    text value: :description, format: 'primary'
  end

  column :request_id, sort: :order_number, label: "Request ID", default: true do
    text value: :request_id, format: 'primary'
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :submitted_at, sort: :submitted_at, default: true do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at do
    date value: :approved_at
  end

  column :status, sort: :status_name, default: true, includes: [:status] do
    badge value: "{{record.status.name | upcase}}", format: :format_status
  end

  column :policy, default: true, includes: [:policy] do
    text value: "{{record.policy.name}}"
  end

  column :amount, default: true, sort: :total_amount_value, includes: [total_amount: :currency] do
    amount value: "{{record.total_amount.value}}",
           currency_code: "{{record.total_amount.currency.country_code}}",
           currency_symbol: "{{record.total_amount.currency.symbol}}"
  end

  column :created_by, default: true, includes: [:creator] do
    user value: :created_by
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_ids
    counts = collection.group(:purchase_request_status_id).count
    counter.add nil, 'All', counts.values.reduce(0, :+)

    # :draft, :retracted
    counter.add 90, 'Open', ((counts[PurchaseRequestStatus.id_for(:draft)] || 0) + (counts[PurchaseRequestStatus.id_for(:retracted)] || 0))

    # :awaiting_approval,
    # if user.has_permission?(:purchase_request_reviewer)
    #   Todo check logic for this from Abi
    #   counter.add 91, 'Awaiting Approval',
    #               collection.where(purchase_request_status_id: PurchaseRequestStatus.id_for(:awaiting_approval), controlling_user_id: user.id).count
    # end

    # :processing
    counter.add PurchaseRequestStatus.id_for(:awaiting_approval), 'Processing', counts[PurchaseRequestStatus.id_for(:awaiting_approval)]

    # :approved, :auto_approved, :po_created, :partially_closed, :order_initiated
    counter.add 92, 'Approved', (
    (counts[PurchaseRequestStatus.id_for(:approved)] || 0) +
        (counts[PurchaseRequestStatus.id_for(:auto_approved)] || 0) +
        (counts[PurchaseRequestStatus.id_for(:po_created)] || 0) +
        (counts[PurchaseRequestStatus.id_for(:partially_closed)] || 0) +
        (counts[PurchaseRequestStatus.id_for(:order_initiated)] || 0)
    )

    # :rejected, :closed, :cancelled,
    [:rejected, :closed, :cancelled].each do |status|
      counter.add PurchaseRequestStatus.id_for(status), status.to_s.titleize, counts[PurchaseRequestStatus.id_for(status)]
    end

    counter
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected, :cancelled
      format = 'danger'
    when :approved, :auto_approved, :closed, :order_initiated, :po_created, :partially_closed
      format = 'success'
    when :awaiting_approval
      # if context[:record].controlling_user_id == context[:user].id
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

end