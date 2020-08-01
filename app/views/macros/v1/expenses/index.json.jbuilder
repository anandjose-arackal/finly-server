includes = [
    {user: [:profile, :default_bank_account]}, :expense_type, :category, :spent_from,
    {manual_expense: {custom_fields: :field_configuration}},
    {distance_expense: [:type, :vehicle_rate, :distance_rate, :distance_unit, :locations]},
    {time_expense: {custom_fields: :field_configuration}},
    {per_diem_expense: [{custom_fields: :field_configuration}, per_diem: [:configurable, :rate]]},
    {card_expense: [:card_transaction, {custom_fields: :field_configuration}]},
    {report: {policy: {time_expense_config: :rate}}},
    {amount: :currency}, {gst_amount: :currency},
    :gst_type,
    :tds_slab,
    :receipts,
    {gstin_location: [:gstin_master, :state]},
    :tax_rate
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'expense', record: record
  end
end