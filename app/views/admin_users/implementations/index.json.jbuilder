json.trails do
  json.array!(@result.paginated_requests) do |implementation_request|
    json.extract! implementation_request, :id,:requested_items, :completed_items, :success_items, :failed_items
    json.initiated_by implementation_request.admin_user&.name
    json.status implementation_request.status&.humanize
    json.request_key implementation_request.request_key&.split('.')&.last
    json.started_at implementation_request.started_at&.to_date&.strftime("%d %B %y")
    json.completed_at implementation_request.completed_at&.to_date&.strftime("%d %B %y")
    json.request_file "/api#{implementation_request.request_file&.url}"
    json.result_file "/api#{implementation_request.result_file&.url}"
  end
end
if @result&.policies.present?
  json.policies do
    json.array!(@result.policies) do |policy|
      json.extract! policy, :id, :name
    end
  end
end
json.count @result.count