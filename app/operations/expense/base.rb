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
    debugger
  end

  def success
    Expense::Base::Presenter.new(user, {expense: self.expense, view: params[:view]}, self.messages)
  end

  class Expense::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense, :violation, :editable

    def init
      self.expense = params[:expense]
      self.violation = retrieve_violation
      self.editable = retrieve_editable
    end

    def retrieve_violation
      violations = {blocking_present: false, wanring_present: false, items: []}
      if expense.report_id and expense.report.policy
        violations = Report::Violation.(user, report: expense.report)
        items = violations[expense.id]
        # constructing the violation hash as required
        violations = {}
        violations[:blocking_present] = (items[:expense_warning].present? or items[:budget_warning].present? or items['expense_warning'].present? or items['budget_warning'].present?)
        violations[:warning_present] = (items[:expense_blocking].present? or items[:budget_blocking].present? or items['expense_blocking'].present? or items['budget_blocking'].present?)
        violations[:items] = items
      end
      violations
    end

    def retrieve_editable

    end
  end


end