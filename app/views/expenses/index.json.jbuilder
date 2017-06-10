json.array!(@result.paginated_expenses) do |expense|
  json.partial! 'expense', expense: expense
end