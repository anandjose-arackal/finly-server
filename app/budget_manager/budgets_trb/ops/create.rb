class BudgetsTrb::Create < Trailblazer::Operation

  step :init!

  def init(options, params:, current_user:, **)
    company = current_user.company
    options["model"] = company.budgets.new
  end
end