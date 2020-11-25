class Docs::AuditTrails::Drawer < Drawer::API

  model AuditTrail
  find_by_key :transaction_id
  policy true
  policy_action :index

  block block_key: :beneficiary, label: "Event", icon: "icon_url" do
    label_value value: :item_type, format: 'standard', label: "Document Type"
    label_value value: :item_id, format: 'standard', label: "Document ID"
    label_value value: "{{record.created_by.name}}", format: 'standard', label: "Actor"
    label_value value: :user_ip, format: 'standard', label: "IP Address"
    label_value value: :created_at, format: 'standard', label: "Date Time"

  end

  block block_key: :changes2, label: "Changes", icon: "icon_url" do
    change value: ["PO_0011", "PO_0021"], label: "Test"
  end

end