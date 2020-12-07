class Docs::AuditTrails::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions :purchase_order_auditor, :po_invoice_auditor, :bank_payment_request_auditor,:admin
  class_attr :record_count

  resolver 'audit_trails.default'
  reference '{{record.transaction_id}}'
  status_filters false

  column :description,  label: "Record Description", fixed: true, default: true do
    text value: "{{record.created_by.name}} {{record.event}}d {{record.item_type}}" , format: "primary"
  end

  column :created_at, label: "DATE & TIME", sort: :created_at, default: true do
    date value: :created_at
  end

  column :changes_less, label: "Changes", default: true do
    text value: :changes_less , format: "standard"
  end

  column :item_type,  label: "Document Type", default: true do
    text value: :parent_document_type, format: "standard"
  end

  column :document_number,  label: "Document Number", default: true do
    text value: :document_number, format: "standard"
  end
  
  column :created_by, default: true, label: "User", includes: [:created_by] do
    text value: "{{record.created_by.name}}", format: 'primary'
    text value: "{{record.created_by.email}}"
  end

  column :event,  label: "Action", default: true do
    text value: :event, format: "standard"
  end

  column :user_ip, label: "User IP", default: true do
    text value: :user_ip, format: "standard"
  end

  column :user_agent, label: "User Agent" do
    text value: :user_agent, format: "standard"
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new
    counter.add nil, "All", collection.count&.count
    counter
  end

  record_count -> (collection) do
    collection.count&.count
  end

end