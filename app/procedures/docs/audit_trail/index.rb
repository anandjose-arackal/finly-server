class Docs::AuditTrail::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :purchase_order_auditor, :po_invoice_auditor, :bank_payment_request_auditor,:admin

  resolver 'audit_trails.default'
  reference '{{record.transaction_id}}'
  # Fixed column is always default true

  column :description,  label: "Record Description", default: true do
    text value: "{{record.created_by.name}} {{record.event}}ed {{record.item_type}}" , format: "primary"
  end

  column :created_at, label: "DATE & TIME", sort: :created_at do
    date value: :created_at
  end

  column :change_set, label: "Changes", default: true do
    text value: :changes , format: "primary"
  end

  column :item_type,  label: "Resources", default: true do
    text value: :item_type, format: "primary"
  end

  column :created_by, default: true, label: "User", includes: [:created_by] do
    user value: :created_by
  end

  column :event,  label: "Action", default: true do
    text value: :event, format: "primary"
  end

  column :user_ip, label: "User IP" do
    text value: :item_type, format: "primary"
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new
    counter.add nil, "All", collection.count
    counter
  end



end