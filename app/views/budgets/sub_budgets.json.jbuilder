case params[:filter_criteria]
when 'budget'
	json.result @result.budget.budget_criteria_as_json
when 'timeline'
	json.result @result.budget.timeline_criteria_as_json
else
	json.result @result.budget.as_json
end
