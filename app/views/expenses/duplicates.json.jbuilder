json.expense do
  json.partial! 'expense', expense: @result.expense
end
json.duplicate_expenses do
  json.array! @result.duplicate_expenses.each do |expense|
    json.partial! 'expense', expense: expense
    json.deletable expense.can_delete?
  end
end