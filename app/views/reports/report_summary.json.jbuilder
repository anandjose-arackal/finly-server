json.non_reimbursable_expenses_total @result.non_reimbursable_expenses_total
json.reimbursable_expenses_total @result.reimbursable_expenses_total
json.card_expenses_total @result.card_expenses_total
json.currency_symbol @result.report.base_currency_symbol
json.currency_country_code @result.report.base_currency_code

json.total @result.report.total_amount
json.base_currency_id @result.report.base_currency_id
json.date @result.report.created_at.strftime('%d %b %Y')

json.violations do
  json.blocking_present @result.has_blocking?
  json.warning_present @result.has_warning?
  json.blocking_messages @result.blocking_array
  json.warning_messages @result.warning_array
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
            json.extract! reviewer, :id, :exception, :threshold, :min, :max
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end

json.reviewal_chain @result.report.get_reviewal_chain
json.tax_rates @result.tax_rates
json.state_codes @result.gst_state_codes
