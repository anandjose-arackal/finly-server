class Docs::AuditTrails::FilterConfig < Filters::API

  DOCUMENT_TYPES = [
      {id: "Purchase Request", name: "Purchase Request"},
      {id: "Purchase Order", name: "Purchase Order"},
      {id: "Invoice", name: "Invoice"},
      {id: "Vendor", name: "Vendor"}
  ]

  DOCUMENT_EVENTS = [
      {id: "create", name: "Create"},
      {id: "Submit", name: "Submit"},
      {id: "update", name: "Update"},
      {id: "Approve", name: "Approve"},
      {id: "Un Approve", name: "Un Approve"},
      {id: "Retract", name: "Retract"},
      {id: "Reject", name: "Reject"},
      {id: "Take Control", name: "Take Control"},
      {id: "Return Control", name: "Return Control"},
      {id: "Forward", name: "Forward"},
      {id: "Void", name: "Void"},
      {id: "Send To Vendor", name: "Send To Vendor"},
      {id: "Vendor Confirmed", name: "Vendor Confirmed"},
      {id: "Deactivate", name: "Deactivate"},
      {id: "Reactivate", name: "Reactivate"}
  ]

  index_builder Docs::AuditTrails::Index

  attribute :document_number, label: "Document Number", type: :text, simple: :true
  attribute :parent_document_type, label: "Document Type", type: :dropdown, simple: true, choices: Choices[:list].(*DOCUMENT_TYPES)
  attribute :created_at, type: :datetime, simple: false
  attribute :event, label: "Action", type: :dropdown, simple: true, choices: Choices[:list].(*DOCUMENT_EVENTS)
  attribute :created_by_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")


end