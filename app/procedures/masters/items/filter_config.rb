class Masters::Items::FilterConfig < Filters::API

  index_builder Masters::Items::Index

  attribute :item_number, label: "Item ID", type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :sku, type: :text
  attribute :rate, type: :number
  attribute :description, type: :text, simple: true
  attribute :item_code, type: :text, simple: true
  attribute :category_id, type: :dropdown, simple: true, choices: Choices[:lookup].('categories')
  attribute :supply_item_type_id, label: "Scope", type: :dropdown, simple: true, choices: Choices[:list].(
      {id: SupplyItemType.id_for(:po_item), name: "PO"},
          {id: SupplyItemType.id_for(:non_po_item), name: "Non-PO"},
          {id: SupplyItemType.id_for(:po_non_po_item), name: 'All'}
  )
  attribute :product_type_id, type: :dropdown, simple: true, choices: Choices[:enum].(ProductType)
  attribute :unit_of_measurement, type: :text
  # attribute :created_by, type: :dropdown, choices: Choices[:lookup].('users', permissions: [:item_master_manager])
  attribute :item_expense_type_id, label: "Expense Type", type: :dropdown, simple: true, choices: Choices[:enum].(ItemExpenseType)
  attribute :tds_applicable, type: :checkbox, choices: Choices[:checkbox].()

end