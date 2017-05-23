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
    self.expense = Expense::Index.(user, params)&.expenses&.find_by(id: id)
  end

  def success
    Expense::Base::Presenter.new(user, {expense: self.expense, view: params[:view]}, self.messages)
  end

  class Expense::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense, :violation, :editable, :view, :per_diems, :converted, :conversion_rate

    def init
      self.expense = params[:expense]
      self.view = params[:view]
      self.violation = retrieve_violation
      self.editable = retrieve_editable
      self.per_diems = retrieve_per_diems(expense)
      self.converted = converted?
      self.conversion_rate = calculate_conversion_rate
    end

    def converted?
      if expense.report.present? && expense.amount.present?
        if expense.report.base_currency_id != expense.amount.currency_id
          return true
        end
      end
      false
    end

    def retrieve_per_diems(expense)
      if expense.report.nil?
        return user.per_diems_list
      else
        if expense.report.policy.present?
          policy = expense.report.policy
          per_diems = policy.per_diems
        else
          company = user.company
          per_diems = company.per_diems
        end
        return per_diems
      end
    end

    def retrieve_violation
      violations = {blocking_present: false, warning_present: false, items: []}
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

    def calculate_conversion_rate
      if expense.report.nil?
        return nil
      else
        converted_amount = expense.amount_value
        original_amount = expense.original_amount_value
        return precision_value converted_amount/original_amount
      end

    end

    def retrieve_editable
      if personal_view?
        if expense.report_id.blank? or expense.report.editable?
          return true
        end
      end
      if expense.report_id.present? and expense.report.processing? and expense.report.controlling_user.id == user.id
        return true
      end
      false
    end
  end


end