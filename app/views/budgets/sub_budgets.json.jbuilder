budget = @op["model"]
case params[:filter_criteria]
when 'budget'
	json.result budget.budget_criteria_as_json
when 'timeline'
	json.result budget.timeline_criteria_as_json
else
	json.result budget.as_json
end
