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
        json.level_name item[:level_name]
        json.level_id item[:level_id]
        if item[:selected_reviewer].present?
          json.selected_reviewer do
            json.reviewer_details item[:selected_reviewer].as_json
            json.threshold item[:selected_reviewer_threshold]
          end
        end
        json.reviewers do
          if current_company.present? && (current_company.id == 2 || current_company.id == 156)
            json.array! item[:reviewer_data] do |data|
              json.id data[:id]
              json.exception data[:exception]
              json.threshold data[:threshold]
              json.reviewer_details do
                min = MathUtil.number_with_rupee_delimiter(data[:min])
                max = (data[:max].to_i == 99999999999999 ? '∞' : MathUtil.number_with_rupee_delimiter(data[:max]))
                json.name "#{data[:reviewer_name]}(#{min} - #{max})"
                json.id data[:reviewer_id]
              end
            end
          else
            json.array! item[:reviewers] do |reviewer|
              json.extract! reviewer, :id, :exception, :threshold
              json.reviewer_details reviewer.reviewer.as_json
            end
          end
        end
      end
    end
  end
end