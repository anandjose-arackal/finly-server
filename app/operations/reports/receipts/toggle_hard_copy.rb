# action to add a receipt to a report.
# params:
# report_id: id of the report to which the receipt needs to be added.

class Reports::Receipts::ToggleHardCopy < Reports::Base

  attr_accessor :report, :toggle_params, :receipt, :hard_copy_received

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init

    self.report = Report.find_by(id: params[:report_id])
    self.receipt = Receipt.find_by(id: params[:receipt_id])

    hard_copy = params[:hard_copy_received]
    if hard_copy.to_i == 0
      self.hard_copy_received = false
    elsif hard_copy.to_i == 1
      self.hard_copy_received = true
    else
      messages[:error] << 'Wrong status for hard copy recived. Please try again'
      return false
    end

    # self.new_receipt_params = receipt_params
  end

  def authorize
    unless report && report.controlling_user_id == user.id
      raise_unauthorized_exception
    end
    unless self.report.open? || self.report.retracted? || self.report.rejected? || self.report.processing?
      messages[:error] << 'Cannot change state of receipt!'
      return false
    end
  end

  def process
    # hardcopy_received = self.receipt.hard_copy_received
    self.receipt.hard_copy_received = self.hard_copy_received
    self.receipt.save
    # self.receipt = report.receipts.build(new_receipt_params)
    # receipt.user = user
    # if receipt.save
    #   self.response = receipt
    # else
    #   messages[:error] = receipt.errors.full_messages
    # end
  end

  def post_process
    # Adding comment to report if its retracted
    if self.report.retracted? || self.report.rejected? || self.report.processing?
      if hard_copy_received
        comment = self.report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:hard_copy_receipt_submitted)
      else
        comment = self.report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:hard_copy_receipt_not_submitted)
      end
      comment.save 
    end
  end
end