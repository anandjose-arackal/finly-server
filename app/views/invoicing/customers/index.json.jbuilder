json.result do
  json.array!(@result.paginated_customers) do |customer|
    json.id customer.id
    json.name customer.name
    json.mobile_number customer.mobile_number
    json.email customer.email
    json.company do
      json.name customer.company.name
    end
    json.description customer.description
    json.virtual_accounts customer.virtual_bank_accounts.pluck(:account_number)
  end
end

json.count @result.count