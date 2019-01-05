# == Schema Information
#
# Table name: report_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



  



class ReportCommentAction < ApplicationRecord

  ACTIONS = {report_comment: 1, report_retract: 2, report_submit: 3, report_auto_submit: 4, report_approve: 5, report_auto_approve: 6,
             report_reject: 7, report_unapprove: 8, report_take_control: 9, report_update: 10, report_settled: 11,
             report_settlement_confirmed: 12, report_closed: 13, report_attach_receipt: 14,
             report_detach_receipt: 15, expense_add: 16, expense_remove: 17, expense_reject: 18, expense_update: 19,
             expense_attach_receipt: 20, expense_detach_receipt: 21, expense_update_receipt: 22, cash_in_hand_deduction_against_reimbursement: 23,
             hard_copy_receipt_submitted: 24,
             hard_copy_receipt_not_submitted: 25
           }

  scope :with_name, -> (name) {where name: name}

  self.class.instance_eval do
    ACTIONS.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(action)
    ACTIONS[action]
  end

  def self.seed_data
    count = ReportCommentAction.count
    ACTIONS.each do |key, value|
      if count == 0 or ReportCommentAction.with_name(key).blank?
        ReportCommentAction.create id: value, name: key
      end
    end
  end
end
