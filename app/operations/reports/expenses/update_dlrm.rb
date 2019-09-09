class Reports::Expenses::UpdateDlrm < BaseOperation
  attr_accessor :report, :updated_expense, :violations

  def pre_validate
    if params.blank?
      add_message :error, 'Error adding comments'
      return
    end
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params[:updated_expense].blank? or not params[:updated_expense].kind_of?(::Expense)
      add_message :error, 'Expense not found'
      return
    end
  end

  def init
    self.updated_expense = params[:updated_expense]
    self.report = self.updated_expense.report
  end

  def validate
    if report.blank?
      add_message :error, 'Report not found'
      return
    end
    if updated_expense.blank?
      add_message :error, 'Expense not found'
      return
    end
    unless report.processing?
      add_message :error, 'Report is not in processing state'
    end

    unless report.get_reviewers.include?(user)
      add_message :error, "Not authorized"
    end
  end

  def pre_process
    self.violations = Reports::Violation.(user, report: self.report)
  end

  def process

    violations_present = has_warning?
    set_params = {
      reviewal_document: report,
      violations_present: violations_present,
      type: 'unaffected'
    }

    ReviewalManager::DocumentReviewalMappings::Set.(user, set_params)
  end


  def has_warning?
    return false unless self.violations.present?
    self.violations.each do |key, violation|
      if violation[:expense_warning].present? or violation[:budget_warning].present? or
          violation['expense_warning'].present? or violation['budget_warning'].present?
        return true
      end
    end
    false
  end
end