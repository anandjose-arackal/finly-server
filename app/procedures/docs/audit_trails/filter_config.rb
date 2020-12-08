class Docs::AuditTrails::FilterConfig < Filters::API

  DOCUMENT_TYPES = [
      {id: "PuchaseOrder", name: "Purchase Order"},
      {id: "Invoice", name: "Invoice"},
      {id: "PuchaseRequest", name: "Purchase Request"},
      {id: "YesBankVendor", name: "Vendor"}
  ]

  index_builder Docs::AuditTrails::Index

  attribute :document_number, label: "Document Number", type: :text, simple: :true
  attribute :parent_document_type, label: "Document Type", type: :dropdown, simple: true, choices: Choices[:list].(*DOCUMENT_TYPES)
  attribute :created_at, type: :datetime, simple: false
  attribute :event, label: "Action", type: :text, simple: true
  attribute :created_by_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")


end