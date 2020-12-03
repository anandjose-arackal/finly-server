class Docs::AuditTrails::FilterConfig < Filters::API

  index_builder Docs::AuditTrails::Index

  attribute :document_number, label: "Document Number", type: :text, simple: :true
  attribute :parent_document_type, label: "Parent Document Type", type: :text, simple: true
  attribute :item_type, label: "Document Type", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :event, label: "Action", type: :text, simple: false
  attribute :created_by_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")

end