class Masters::Items::Master < Masters::API

  UNITS_OF_MEASUREMENT = ["BOU", "Bags", "Bale", "Bottles", "Boxes", "Buckles", "Bunches", "Bundles", "Cans", "Carat", "Cartons", "Centimeter", "Cubic Centimeter", "Cubic Meter", "Dozen", "Drums", "Grams", "Great Gross", "Gross", "Gross Yards", "Kilograms", "Kiloliter", "Kilometers", "Liters", "Lump Sum", "Meter", "Metric Ton", "Milliliters", "Month", "Numbers", "Others", "Packs", "Pairs", "Pieces", "Quintal", "Rolls", "Sets", "Square Feet", "Square Meter", "Square Yards", "Tablets", "Ten Grams", "Thousands", "Tonnes", "Tubes", "US Gallons", "Units", "Yards", "Years", "Quarter"]

  model Item

  schema do
    sequence :item_number, prefix: 'ITEM/', min_length: 6, show_in_lookup: true
    text :description, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :sku
    lookup :category_id, choices_scope: Choices[:lookup].('masters.categories'), required: true
    large_text :note
    # lookup :tax_rate_id, choices_scope: Choices[:lookup].('masters.tax_rates')
    # text :account, label: 'Account Code'
    # dropdown :item_scope_id, choices_scope: Choices[:list].({id: 'PO', name: "PO"}, {id: 'Non PO', name: "Non PO"}, {id: 'Any', name: "Any"})
    # dropdown :item_type_id, choices_scope: Choices[:list].({id: 'Goods', name: 'Goods'}, {id: 'Service', name: 'Service'})
    # dropdown :nature_of_expense_id, choices_scope: Choices[:list].({id: 'Capex', name: 'Capex'}, {id: 'Opex', name: 'Opex'})
    # dropdown :unit_of_measurement_id, choices_scope: Choices[:list].(*UNITS_OF_MEASUREMENT)
  end

end