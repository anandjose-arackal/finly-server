json.data do
  json.array! @result.companies, :id, :name, :pending_assign_request_count
end