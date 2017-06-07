json.success @result.success?
json.confirm_approve params[:confirm_approve] || false
json.messages @result.messages

json.reports do
  json.array!(@result.reports_with_data) do |ob|
    json.report do
      json.extract! ob[:report], :id, :name
      json.status_name ob[:report].report_status.name
      json.total ob[:report].total_amount
      json.non_reimbursable_expenses_total ob[:report].total_amount(:non_reimbursable)
      json.reimbursable_expenses_total ob[:report].total_amount(:reimbursable)
      json.card_expenses_total ob[:report].total_amount(:only_card_expenses)
      json.currency_symbol ob[:report].base_currency_symbol
      json.currency_country_code ob[:report].base_currency_code
      json.expenses_count ob[:report].expenses.count
      json.policy ob[:report].policy.name
      json.date ob[:report].created_at.strftime('%d %b %Y')
    end
    json.user do
      json.extract! ob[:report].user, :id, :name
    end
    json.errors ob[:errors]
    json.notices ob[:notices]

    json.violations ob[:violations]
  end
end