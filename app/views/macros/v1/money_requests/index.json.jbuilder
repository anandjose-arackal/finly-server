includes = [
  {user: [:profile, :default_bank_account]},
  :status,
  :policy,
  :payment_mode,
  :items
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'money_request', record: record
  end
end