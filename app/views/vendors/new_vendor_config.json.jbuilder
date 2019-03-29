json.vendor_approval_workflow @result.vendor_approval_workflow
json.codes do
  json.array! @result.states, :id, :name
end
json.vendor_types do
  json.array! @result.vendor_types, :id, :name
end

json.payment_terms do
  json.array! @result.payment_terms, :id, :name, :description
end

json.currencies do
  json.array! @result.currencies do |currency|
    json.merge! currency.as_json
  end
end

json.tds_rates do
  json.array! @result.tds_rates do |tds_rate|
    json.extract! tds_rate, :id, :name, :tds
  end
end

json.custom_fields_config @result.field_configurations

json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end

json.locations do
  json.array! @result.locations do |location|
    json.extract! location, :id, :name
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

json.actions @result.actions