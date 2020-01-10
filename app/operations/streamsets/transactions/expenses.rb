class Streamsets::Transactions::Expenses < BaseOperation
	attr_accessor :expenses

  def pre_validate

  end

  def init
  	op = Report::Index.(current_user, params)
  	if op.failure?
  		add_message :error, op.messages[:error]
  		return
  	end
  	reports = op.reports
  	self.expenses = Expense.where(company_id: user.company_id, report_id: reports.pluck(:id))

  end

end