class BudgetGroups::Create < Trailblazer::Operation

  
  step :init!


  def init(options, params:, current_user:, **)
    company = current_user.company
    debugger
    options["model"] = company.budget_groups.new
  end
end