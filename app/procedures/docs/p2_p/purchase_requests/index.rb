class Docs::P2P::PurchaseRequests::Index < IndexBuilder::API

  resolver 'purchase_requests.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :request, label: 'Name', fixed: true do
    text value: :description, format: 'primary'
  end

  column :request_id, sort: :order_number, label: "Request ID", default: true do
    badge value: :request_id, format: "success"
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

  column :amount, default: true, sort: :total_amount_value, includes: [:total_amount] do
    amount value: "{{record.total_amount.value}}",
           currency_code: "{{record.total_amount.currency.country_code}}",
           currency_symbol: "{{record.total_amount.currency.symbol}}"
  end

  column :created_by, default: true, includes: [:creator] do
    user value: :created_by
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :purchase_request_status_id
    counts = collection.group(:purchase_request_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    PurchaseRequestStatus.all.each do |status|
      counter.add status.id, status.name.humanize, counts[status.id]
    end
    counter
  end

  def self.format_status(user, record, record_exposure)
    case record.status&.name&.to_s&.to_sym
    when :rejected, :cancelled
      format = 'danger'
    when :approved, :auto_approved, :closed, :order_initiated, :po_created, :partially_closed
      format = 'success'
    when :awaiting_approval
      # if record.controlling_user_id == user
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