class Masters::Items::FilterConfig < Filters::API

  attribute :item_number, label: "Item ID", type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :sku, type: :text
  attribute :rate, type: :number
  attribute :description, type: :text, simple: true
  attribute :item_code, type: :text, simple: true
  attribute :category, type: :dropdown, simple: true, choices: Choices[:auto_complete].('categories')
  attribute :supply_item_type_id, label: "Scope", type: :dropdown, simple: true, choices: Choices[:enum].(SupplyItemType)
  attribute :product_type_id, type: :dropdown, simple: true, choices: Choices[:enum].(ProductType)
  attribute :unit_of_measurement, type: :text
  # attribute :created_by, type: :dropdown, choices: Choices[:auto_complete].('users', permissions: [:item_master_manager])
  attribute :item_expense_type_id, label: "Expense Type", type: :dropdown, simple: true, choices: Choices[:enum].(ItemExpenseType)
  attribute :tds_applicable, choices: Choices[:checkbox].()

end