class Docs::UtilityBills::Bills::FilterConfig < Filters::API

  attribute :bill_id, label: 'Bill ID', type: :text, simple: true
  attribute :bill_number, label: 'Bill Number', type: :text, simple: true
  attribute :created_at, type: :datetime, simple: false
  attribute :updated_at, type: :datetime, simple: false
  attribute :bill_date, label: 'Bill Date', type: :datetime, simple: true
  attribute :due_date, label: 'Due Date', type: :datetime, simple: true
  attribute :subscription_biller_biller_category_name, label: "Biller Category Name", type: :text
  attribute :policy, type: :dropdown, simple: false, choices: Choices[:auto_complete].('policies')
  attribute :bbps_biller_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].('bbps_billers')
  attribute :subscription_category_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].('categories')
  attribute :subscription_sequence_id, label: 'Subscription ID', type: :text
  attribute :subscription_name, label: 'Subscription Name', type: :text

end