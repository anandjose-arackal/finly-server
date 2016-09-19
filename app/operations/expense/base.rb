class Expense::Base < BaseOperation
  attr_accessor :expense

  def authorized_user_types
    [:employee, :manager, :admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    id = (params[:expense_id] or params[:id])
    self.expense = Expense::Index.(user, params).expenses.with_id(id).first rescue nil
  end

  def success
    Expense::Base::Presenter.new(user, {expense: self.expense}, self.messages)
  end

  class Expense::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense, :violation

    def init
      self.expense = params[:expense]
      self.violation = retrieve_violation
    end

    def retrieve_violation
      if expense.report_id and expense.report.policy
        violations = Report::Violation.(user, report: expense.report)
        return violations[expense.id]
      end
    end
  end


end