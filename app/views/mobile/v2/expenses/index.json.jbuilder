json.expenses do
  cash_pockets = @result.cash_pockets
  json.array! @result.paginated_expenses do |expense|
    json.partial! 'expense', expense: expense, cash_pockets: cash_pockets
  end
end
json.filter do
  json.categories do
    json.array! @result.categories do |category|
      json.id category.id
      json.name category.name
    end
  end
end
json.currencies do
  json.array!(Currency.all) do |currency|
    json.country currency.country
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end