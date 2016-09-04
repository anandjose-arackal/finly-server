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

  ACTIONS = {report_comment: 1, report_retract: 2, report_submit: 3, report_approve: 4, report_auto_approve: 5,
             report_reject: 6, report_unapprove: 7, report_take_control: 8, report_update: 9, report_reimbursed: 10,
             report_reimbursement_confirmed: 11, report_closed: 12, report_attach_receipt: 13,
             report_detach_receipt: 14, expense_add: 15, expense_remove: 16, expense_reject: 17, expense_update: 18}

  self.class.instance_eval do
    ACTIONS.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

end
