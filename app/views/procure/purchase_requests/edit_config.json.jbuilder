json.locations do
  json.array!(@result.locations.include_state) do |location|
    json.merge! location.as_json(tree: true)
    # json.id location.id
    # json.name location.name
  end
end

json.departments do
  json.array!(@result.departments) do |department|
    json.merge! department.as_json(tree: true)
    # json.id department.id
    # json.name department.name
  end
end

json.policies do
  json.array!(@result.policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end

json.department_mappings @result.department_mappings
json.location_mappings @result.location_mappings

json.cost_centers @result.cost_centers.as_json

json.pr_item_categories do
  json.array!(current_company.categories.inward_invoice_items_only) do |category|
    json.id category.id
    json.name category.name
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
json.reviewal_chain @result&.purchase_request&.get_reviewal_chain