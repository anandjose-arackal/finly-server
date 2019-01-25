json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end
json.reviewal_chains do
  json.array! @result.reviewal_chains do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_id item[:level_id]
        json.selected_reviewer item[:selected_reviewer]&.as_json
        json.selected_reviewer_threshold item[:selected_reviewer_threshold]
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