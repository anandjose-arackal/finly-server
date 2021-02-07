class Docs::UtilityBills::Bills::FilterConfig < Filters::API


  index_builder Docs::UtilityBills::Bills::Index
  BBPS_BILLER_CATEGORY_CHOICES = [{id:"Electricity", name:"Electricity"}, {id:"Gas", name:"Gas"}, {id:"Mobile Postpaid", name:"Mobile Postpaid"}, {id:"Landline Postpaid", name:"Landline Postpaid"}, {id:"DTH", name:"DTH"}, {id:"Broadband Postpaid", name:"Broadband Postpaid"}, {id:"Water", name:"Water"}, {id:"LPG Gas", name:"LPG Gas"}, {id:"Loan Repayment", name:"Loan Repayment"}, {id:"Life Insurance", name:"Life Insurance"}, {id:"Fastag", name:"Fastag"}, {id:"Cable TV", name:"Cable TV"}, {id:"Health Insurance", name:"Health Insurance"}].freeze

  attribute :sequence_id, label: 'Bill ID', type: :text, simple: true
  attribute :bill_number, label: 'Bill Number', type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :submitted_at, type: :datetime
  attribute :approved_at, type: :datetime
  attribute :bill_date, label: 'Bill Date', type: :datetime, simple: true
  attribute :due_date, label: 'Due Date', type: :datetime, simple: true
  attribute :subscription_biller_biller_category_name, label: "Biller Category Name", type: :dropdown, choices: Choices[:list].(*BBPS_BILLER_CATEGORY_CHOICES)
  attribute :policy_id, type: :dropdown, choices: Choices[:lookup].('policies')
  attribute :bbps_biller_id, type: :dropdown, simple: true, choices: Choices[:lookup].('bbps_billers')
  attribute :subscription_category_id, type: :dropdown, simple: true, choices: Choices[:lookup].('categories')
  attribute :subscription_sequence_id, label: 'Subscription ID', type: :text
  attribute :subscription_name, label: 'Subscription Name', type: :text
  attribute :location_id, label: "Location", type: :dropdown, choices: Choices[:lookup].("locations")
  attribute :cost_center_id, label: "Cost Center", type: :dropdown, choices: Choices[:lookup].("cost_centers")
  attribute :department_id, label: "Department", type: :dropdown, choices: Choices[:lookup].("departments")
  attribute :user_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")
  attribute :controlling_level_level_number, label: "Controlling Level", type: :number, simple: true
  attribute :controlling_user, label: "Controlling User", type: :dropdown, simple: true, choices: Choices[:lookup].("users")

end