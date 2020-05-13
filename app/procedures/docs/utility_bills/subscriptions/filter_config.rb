class Docs::UtilityBills::Subscriptions::FilterConfig < Filters::API

  attribute :name, type: :text, simple: true
  attribute :bbps_biller_id, label: "Biller", type: :dropdown, simple: true, choices: Choices[:auto_complete].('bbps_billers')
  attribute :sequence_id, label: "Subscription ID", type: :text
  attribute :biller_biller_category_name, label: "Biller Category Name", type: :dropdown, choices: Choices[:list].(*Docs::UtilityBills::Bills::FilterConfig::BBPS_BILLER_CATEGORY_CHOICES), simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :submitted_at, type: :datetime
  attribute :approved_at, type: :datetime
  attribute :status_id, label: "Status", type: :dropdown, choices: Choices[:enum].(BbpsBillerSubscriptionStatus)
  attribute :category_id, label: "Category", simple: true, type: :dropdown, choices: Choices[:auto_complete].("categories")
  attribute :location_id, label: "Location", type: :dropdown, choices: Choices[:auto_complete].("locations")
  attribute :cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:auto_complete].("cost_centers")
  attribute :department_id, label: "Department", type: :dropdown, choices: Choices[:auto_complete].("departments")
  attribute :policy_id, label: "Policy", type: :dropdown, choices: Choices[:auto_complete].("policies")
  # attribute :last_paid_at, type: :datetime

end