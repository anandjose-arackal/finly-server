# placeholder class that helps distinguish between reimbursable and non-reimbursable expenses

class QuickbooksReportConfig

  attr_accessor :reimbursable, :expenses, :report, :account_id, :user, :date,
                :quickbooks_department_id, :payee_id

  def initialize(user, reimbursable, expenses, options = {})
    self.user = user
    self.reimbursable = reimbursable
    self.expenses = expenses
    self.report = expenses.first.report
    self.quickbooks_department_id = options[:department_id]
    self.payee_id = user.quickbooks_user&.id
  end

  def payment_type_quickbooks_id(reimbursable)
    company_id = self.user.company_id
    qb = QuickbooksConfiguration.find_by(company_id: company_id)
    if reimbursable
      return qb.reimbursable_account&.quickbooks_id
    else
      return qb.non_reimbursable_account&.quickbooks_id
    end
  end
end
