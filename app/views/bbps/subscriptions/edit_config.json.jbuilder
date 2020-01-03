json.result do
  json.types do
    json.array! @op['result']['types']
  end

  json.departments {json.array! @op['result']['departments']}
  json.cost_centers {json.array! @op['result']['cost_centers']}
  json.policies {json.array! @op['result']['policies']}
  json.locations {json.array! @op['result']['locations']}
  json.categories {json.array! @op['result']['categories']}
  json.tax_rates {json.array! @op['result']['tax_rates']}

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