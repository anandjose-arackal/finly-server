json.success @op.success?

json.result do
  json.types do
    json.array! @op['result']['types']
  end

  json.policies {json.array! @op['result']['policies']}

  json.reviewal_chains do
    json.array! @op['result']['reviewal_chains'] do |chain|
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
              json.extract! reviewer, :id, :exception, :threshold, :min, :max
              json.reviewer_details reviewer.reviewer.as_json
            end
          end
        end
      end
    end
  end
end