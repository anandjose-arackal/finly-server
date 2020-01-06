json.result do
  json.array!(@result.paginated_payments) do |payment|

  end
end
json.count @result.count