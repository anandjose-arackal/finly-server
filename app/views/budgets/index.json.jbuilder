json.array! @result.budgets do |budget|
  json.extract! budget, :id, :name, :start_date, :end_date
end