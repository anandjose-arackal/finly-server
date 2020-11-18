class Docs::AuditTrails::FilterConfig < Filters::API

  index_builder Docs::AuditTrails::Index

  attribute :item_type, label: "Resources", type: :text, simple: true
  attribute :item_id, label: "Resource ID", type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :event, label: "Action", type: :text, simple: false
  attribute :created_by_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")

end