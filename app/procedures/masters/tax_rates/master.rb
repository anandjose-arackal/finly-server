class Masters::TaxRates::Master < Masters::API

  model TaxRate
  name "Tax Rates"

  schema has_nesting: false do
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    decimal :rate, show_in_lookup: true
    date :start_date
    date :end_date
  end


end