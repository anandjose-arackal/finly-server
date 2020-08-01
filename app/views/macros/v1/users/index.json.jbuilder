includes = [
    :profile, :default_bank_account
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'user', record: record
  end
end