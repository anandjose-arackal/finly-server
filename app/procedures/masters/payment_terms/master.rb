class Masters::PaymentTerms::Master < Masters::API

  model PaymentTerm
  name "Payment Terms"

  schema do
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    integer :days_after, label: "Days from Invoice Date"
    large_text :description
    switch :default
    date :start_date
    date :end_date
  end


end