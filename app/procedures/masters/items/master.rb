class Masters::Items::Master < Masters::API

  UNITS_OF_MEASUREMENT = ["BOU", "Bags", "Bale", "Bottles", "Boxes", "Buckles", "Bunches", "Bundles", "Cans", "Carat", "Cartons", "Centimeter", "Cubic Centimeter", "Cubic Meter", "Dozen", "Drums", "Grams", "Great Gross", "Gross", "Gross Yards", "Kilograms", "Kiloliter", "Kilometers", "Liters", "Lump Sum", "Meter", "Metric Ton", "Milliliters", "Month", "Numbers", "Others", "Packs", "Pairs", "Pieces", "Quintal","RFeet", "Rolls", "Sets", "Square Feet", "Square Meter", "Square Yards", "Tablets", "Ten Grams", "Thousands", "Tonnes", "Truck Load", "Tubes", "US Gallons", "Units", "Yards", "Years", "Quarter"]

  model Item
  name "Items"

  schema do
    sequence :item_number, prefix: 'ITEM', min_length: 6, show_in_lookup: true
    text :description, required: true, show_in_lookup: true, unique: true, primary_key: true
    dropdown :supply_item_type_id, choices_scope: Choices[:enum].(::SupplyItemType)
    text :sku
    lookup :category_id, choices_scope: Choices[:lookup].('masters.categories'), required: true
    text :hsn_sac
    decimal :rate
    lookup :tax_rate_id, choices_scope: Choices[:lookup].('masters.tax_rates')
    dropdown :unit_of_measurement, choices_scope: Choices[:list].(*UNITS_OF_MEASUREMENT.map { |unit| { id: unit, name: unit } })
    dropdown :product_type_id, choices_scope: Choices[:enum].(::ProductType)
    switch :tds_applicable
    dropdown :item_expense_type_id, choices_scope: Choices[:enum].(::ItemExpenseType)
    large_text :note
  end

end