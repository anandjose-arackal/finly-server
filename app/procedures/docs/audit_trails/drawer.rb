class Docs::AuditTrails::Drawer < Drawer::API

  model AuditTrail
  find_by_key :transaction_id
  policy true
  policy_action :index

  block block_key: :beneficiary, label: "Event", icon: "icon_url" do
    text value: :item_type, format: 'standard', label: "Document Type"
    text value: :item_id, format: 'standard', label: "Document ID"
    text value: "{{record.created_by.name}}", format: 'standard', label: "Actor"
    text value: :user_ip, format: 'standard', label: "IP Address"
    text value: :created_at, format: 'standard', label: "Date Time"

  end

  block block_key: :changes, label: "Changes", icon: "icon_url" do
    change value: ["PO_001", ["PO_002"]], label: "Test"
  end

end