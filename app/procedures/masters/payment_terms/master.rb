class Masters::PaymentTerms::Master < Masters::API

  model PaymentTerm

  schema do
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    large_text :description
    switch :default
    date :start_date
    date :end_date
  end


end