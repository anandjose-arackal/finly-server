class Masters::Users::FilterConfig < Filters::API

  attribute :first_name, type: :text, simple: true
  attribute :last_name, type: :text, simple: true
  attribute :last_activity_at, type: :datetime
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :status, type: :dropdown, simple: true, choices: Choices[:list].({id: "1", name: "Active"}, {id: "2", name: "Pending"}, {id: "3", name: "Inactive"})
  attribute :location_id, type: :dropdown, simple: true, choices: Choices[:lookup].("locations")
  attribute :department_id, type: :dropdown, simple: true, choices: Choices[:lookup].("departments")
  attribute :cost_center_id, type: :dropdown, simple: true, choices: Choices[:lookup].("cost_centers")

end