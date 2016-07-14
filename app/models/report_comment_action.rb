# == Schema Information
#
# Table name: report_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReportCommentAction < ActiveRecord::Base

  def self.report_comment_id
    1
  end

  def self.report_retract_id
    2
  end

  def self.report_submit_id
    3
  end

  def self.report_approve_id
    4
  end

  def self.report_auto_approve_id
    5
  end

  def self.report_reject_id
    6
  end

  def self.report_unapprove_id
    7
  end

  def self.report_reimburse_id
    8
  end

  def self.report_reimbursement_received_id
    9
  end

  def self.report_take_control_id
    10
  end

  def self.report_update_id
    11
  end

  def self.report_attach_receipt_id
    12
  end

  def self.expense_add_id
    13
  end

  def self.expense_remove_id
    14
  end

  def self.expense_reject_id
    15
  end

  def self.expense_update_id
    16
  end

end
