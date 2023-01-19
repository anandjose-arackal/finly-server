json.trails do
  json.array!(@result.paginated_requests) do |common_import_request|
    json.extract! common_import_request, :id
    json.requested_items common_import_request.requested_items&.to_s || '0'
    json.completed_items common_import_request.completed_items&.to_s || '0'
    json.success_items common_import_request.success_items&.to_s || '0'
    json.failed_items common_import_request.failed_items&.to_s || '0'
    json.initiated_by common_import_request.user&.name
    json.status common_import_request.status&.humanize
    json.request_key common_import_request.request_key&.split('.')&.last
    json.started_at common_import_request.started_at&.strftime("%d %B %y %T")
    json.completed_at common_import_request.completed_at&.strftime("%d %B %y %T")
    json.request_file  common_import_request.request_file.file? ? "#{common_import_request.request_file&.url}" : nil
    json.result_file common_import_request.result_file.file? ? "#{common_import_request.result_file&.url}" : nil
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