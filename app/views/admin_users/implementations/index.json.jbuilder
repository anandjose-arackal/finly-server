json.array!(@result.paginated_requests) do |implementation_request|
  json.extract! implementation_request, :id,:request_key,:status, :requested_items, :completed_items, :success_items, :failed_items
  json.initiated_by implementation_request.admin_user&.name
  json.started_at implementation_request.started_at&.to_date&.strftime("%d %B %y")
  json.completed_at implementation_request.completed_at&.to_date&.strftime("%d %B %y")
  json.request_file implementation_request.request_file&.url
  json.result_file  implementation_request.result_file&.url
end