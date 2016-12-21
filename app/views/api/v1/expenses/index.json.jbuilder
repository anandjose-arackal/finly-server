json.expenses do
  json.array! @result.paginated_expenses do |expense|
    json.partial! 'expense', expense: expense
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