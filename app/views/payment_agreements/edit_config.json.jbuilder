json.locations do
  if @result.locations.present?
    json.array!(@result.locations.include_state) do |location|
      json.merge! location.as_json(tree: true)
    end
  end
end


json.departments do
  json.array!(@result.departments) do |department|
    json.merge! department.as_json(tree: true)
  end
end

json.department_mappings @result.department_mappings

json.cost_centers @result.cost_centers.as_json

json.policies do
  json.array!(@result.policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end


json.reviewal_chains do
  json.array! @result.reviewal_chains do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_name item[:level_name]
        json.level_id item[:level_id]
        if item[:selected_reviewer].present?
          json.selected_reviewer do
            json.reviewer_details item[:selected_reviewer].as_json
            json.threshold item[:selected_reviewer_threshold]
          end
        end
        json.reviewers do
          json.array! item[:reviewers] do |reviewer|
            json.extract! reviewer, :id, :exception, :threshold
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end
json.reviewal_chain @result&.payment_agreement&.get_reviewal_chain