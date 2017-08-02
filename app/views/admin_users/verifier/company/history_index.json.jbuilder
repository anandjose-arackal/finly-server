json.array! @result.companies do |company|
  # , :id, :name, :pending_assign_request_count, :pending_upgrade_request_count
  json.id company.id
  json.name company.name
  json.pending_assign_request_count @result.assign_request_count_for company
  json.pending_upgrade_request_count @result.upgrade_request_count_for company
end