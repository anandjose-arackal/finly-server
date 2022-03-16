includes = [
  :status,
  :created_by, 
  :policy,
  user: [:profile, :default_bank_account],
  :destination_pocket,
  :payment_mode,
  {amount: :currency},
  {items: :category},
  {money_request: {custom_fields: :field_configuration}}
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'money_request', record: record
  end
end