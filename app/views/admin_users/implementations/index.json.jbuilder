json.trails do
  json.array!(@result.paginated_requests) do |implementation_request|
    json.extract! implementation_request, :id
    json.requested_items implementation_request.requested_items&.to_s || '0'
    json.completed_items implementation_request.completed_items&.to_s || '0'
    json.success_items implementation_request.success_items&.to_s || '0'
    json.failed_items implementation_request.failed_items&.to_s || '0'
    json.initiated_by implementation_request.admin_user&.name
    json.status implementation_request.status&.humanize
    json.request_key implementation_request.request_key&.split('.')&.last
    json.started_at implementation_request.started_at&.strftime("%d %B %y %T")
    json.completed_at implementation_request.completed_at&.strftime("%d %B %y %T")
    json.request_file  implementation_request.request_file.file? ? "#{implementation_request.request_file&.url}" : nil
    json.result_file implementation_request.result_file.file? ? "#{implementation_request.result_file&.url}" : nil
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