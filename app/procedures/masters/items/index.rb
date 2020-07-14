class Masters::Items::Index < IndexBuilder::API

  system_subscription :vp
  permissions :item_master_manager, :inventory_manager, :auditor, :admin
  resolver 'items.default'
  reference '{{record.id}}'
  custom_fields :item

  # Fixed column is always default true
  column :description, fixed: true, sort: :description do
    text value: '{{record.description}}', format: 'primary'
  end

  column :item_number, label: "Item ID", sort: :item_number, default: true do
    text value: :item_number, format: "primary"
  end

  column :item_code, sort: :item_code, default: true do
    text value: :item_code
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :updated_at, sort: :updated_at do
    date value: :updated_at
  end

  column :created_by, default: true, sort: :created_by_id, includes: [:created_by] do
    user value: :created_by
  end

  column :category, default: true, sort: :category_id, includes: [:category] do
    text value: '{{record.category.name}}'
  end

  column :expense_type, default: true, sort: :item_expense_type_id, includes: [:item_expense_type] do
    text value: '{{record.expense_type | upcase}}'
  end

  column :product_type, default: true, sort: :product_type_id, includes: [:product_type] do
    text value: '{{record.product_type | upcase}}'
  end

  # column :active, default: true, sort: :active do
  #   checkbox value: '{{record.active}}'
  # end

  column :tds_applicable, default: true, label: "TDS Applicable", sort: :tds_applicable do
    checkbox value: '{{record.tds_applicable}}'
  end

  column :unit_of_measurement, default: true, sort: :unit_of_measurement do
    text value: :unit_of_measurement
  end

  column :scope, default: true, sort: :supply_item_type_id do
    text value: '{{record.scope | upcase}}'
  end

  column :tax_rate, sort: :tax_rate_id, includes: [:tax_rate] do
    text value: '{{record.tax_rate.full_name}}'
  end

  column :rate, default: true, sort: :rate do
    amount value: '{{record.rate}}', currency_code: 'INR', currency_symbol: '₹'
  end

  column :sku, default: true, sort: :sku do
    text value: :sku
  end

  column :hsn_sac, sort: :hsn_sac do
    text value: :hsn_sac
  end

  # Counter is not required for item master
  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :active_eq
    counts = collection.group(:active).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    # counter.add '1', "Active", counts[true]
    # counter.add '0', "Deactivated", counts[false]

    counter
  end

end