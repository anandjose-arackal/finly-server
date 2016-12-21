class Report::Expenses::UpdateComment < BaseOperation
  attr_accessor :report, :updated_expense, :updated_attributes

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
    if params[:updated_attributes].blank? or not params[:updated_attributes].kind_of?(Hash)
      add_message :error, 'Nothing to update'
    end
  end

  def init
    self.updated_attributes = params[:updated_attributes]
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
    if updated_attributes.blank? or not updated_attributes.kind_of?(Hash)
      add_message :error, 'Nothing to update'
      return
    end
    unless report.retracted? or report.rejected? or report.processing?
      add_message :error, 'Cannot add comments in the current state'
    end
  end

  def process
    updated_attributes.each do |key, value|
      next if key.blank?
      key = key.to_sym
      if key == :receipt
        if value > updated_expense.receipts.count
          # i.e. if a receipt was removed
          report.comments.create(report_comment_action_id: ReportCommentAction.id_for(:expense_detach_receipt),
                                 user_id: self.user.id,
                                 expense_id: updated_expense.id)
        elsif value < updated_expense.receipts.count
          # i.e. if a receipt was added
          report.comments.create(report_comment_action_id: ReportCommentAction.id_for(:expense_attach_receipt),
                                 user_id: self.user.id,
                                 expense_id: updated_expense.id)
        elsif updated_expense.receipts.count > 0
          # i.e if a receipt was updated
          report.comments.create(report_comment_action_id: ReportCommentAction.id_for(:expense_update_receipt),
                                 user_id: self.user.id,
                                 expense_id: updated_expense.id)
        end
      elsif updated_expense.send(key) != value and not (updated_expense.send(key).blank? and value.blank?)
        report.comments.create(report_comment_action_id: ReportCommentAction.id_for(:expense_update),
                               user_id: self.user.id,
                               updated_field: key.to_s.humanize,
                               updated_from: value,
                               updated_to: updated_expense.send(key),
                               expense_id: updated_expense.id)
      end
    end
  end
end