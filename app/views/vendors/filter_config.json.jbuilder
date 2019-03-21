json.vendor_types do
  json.array! @result.vendor_types, :id, :name
end

if @result.policies.present?
  
end

if @result.vendor_empanelment_workflow_enabled
  json.policies do
    json.array! @result.policies do |policy|
      json.extract! policy, :id, :name
    end
  end

  json.statuses do
    json.array! @result.vendor_statuses do |status|
      json.merge! status.as_json
    end
  end
end
