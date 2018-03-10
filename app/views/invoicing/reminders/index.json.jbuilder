json.array!(@result.reminders) do |reminder|
  json.extract! reminder, :days, :reference_date_type, :timeframe_type, :name, :id
end