json.result do
  json.array!(@result.paginated_expenses) do |expense|
    json.partial! 'expense', expense: expense
  end
end
json.count @result.count