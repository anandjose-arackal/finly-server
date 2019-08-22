class Reports::Expenses::UpdateDlrm < BaseOperation
  attr_accessor :report, :updated_expense

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

  def process
    set_params = {
      reviewal_document: report,
      violations_present: violation_present,
    }

    ReviewalManager::DocumentReviewalMappings::Set.(user, set_params)
  end
end