json.array!(@result.companies) do |company|
  json.extract! company, :name, :id
  json.created_at company.created_at.to_date.strftime("%d %B %y")
  json.balance company.balance_amount(DateUtils.local_date)
  json.active company.active
end
