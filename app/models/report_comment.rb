# == Schema Information
#
# Table name: report_comments
#
#  id                       :integer          not null, primary key
#  report_id                :integer          not null
#  report_comment_action_id :integer          not null
#  user_id                  :integer
#  expense_id               :integer
#  updated_field            :string(255)
#  updated_from             :text(65535)
#  updated_to               :text(65535)
#  rejected_to_id           :integer
#  content                  :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  payment_id               :integer
#

class ReportComment < ActiveRecord::Base
  belongs_to :report
  belongs_to :user
  belongs_to :report_comment_action
  belongs_to :expense
  belongs_to :rejected_to, class_name: 'User'
  belongs_to :payment

  validates :report_id, presence: true
  validates :report_comment_action_id, presence: true
  validate :associations

  default_scope { order created_at: :desc }

  def generate(u = nil)
    comment = nil
    name = nil
    if self.user.present? and u.present? and u.id == self.user_id
      name = "You"
    elsif self.user.present?
      name = self.user.name
    end
    case report_comment_action_id
      when ReportCommentAction.report_comment_id
        # Report comment
        comment = "#{name} commented : #{content}"
      when ReportCommentAction.report_retract_id
        # Report retract
        comment = "#{name} has retracted the report"
      when ReportCommentAction.report_submit_id
        # Report submit
        comment = "#{name} submitted the report"
      when ReportCommentAction.report_approve_id
        # Report approve
        comment = "#{name} approved the report"
      when ReportCommentAction.report_auto_approve_id
        # Report auto_approve
        comment = "Report auto-approved as no manager is assigned to the user"
      when ReportCommentAction.report_reject_id
        # Report reject
        comment = "#{name} rejected the report"
        if content.present?
          comment += " with a note : #{content}"
        end
      when ReportCommentAction.report_unapprove_id
        # Report unapprove
        comment = "#{name} has unapproved the report"
      when ReportCommentAction.report_take_control_id
        # Report take control
        comment = "#{name} took control of the report"
      when ReportCommentAction.report_update_id
        # Report update
        comment = "#{name} has updated #{updated_field} from #{updated_from} to #{updated_to}"
      when ReportCommentAction.report_reimbursed_id
        # Report reimbursed
        comment = "#{name} has reimbursed the report with Payment ID : #{payment.id}"
        if payment.note.present?
          comment += " , note : #{payment.note}"
        end
      when ReportCommentAction.report_reimbursement_confirmed_id
        # Report reimbursement confirmed
        comment = "#{name} has confirmed that the reimbursement is received"
      when ReportCommentAction.report_closed_id
        # Report closed
        comment = "Report is marked as closed"
      when ReportCommentAction.report_attach_receipt_id
        # Report attach receipt
        comment = "#{name} has attached the report"
      when ReportCommentAction.report_detach_receipt_id
        # Report detach receipt
        comment = "#{name} has detacted the report"
      when ReportCommentAction.expense_add_id
        # Expense add
        comment = "#{name} has added expense at : #{expense.merchant_name} to the report"
      when ReportCommentAction.expense_remove_id
        # Expense remove
        comment = "#{name} has remove expense at : #{expense.merchant_name} to the report"
      when ReportCommentAction.expense_reject_id
        # Expense reject
        comment = "#{name} rejected the expense at : #{expense.merchant_name}"
        if expense.note.present?
          comment += " with a note : #{content}"
        end
      when ReportCommentAction.expense_update_id
        # Expense update
        comment = "#{name} updated the expense at : #{expense.merchant_name}. #{updated_field} from #{updated_from} to #{updated_to}"
    end
    comment
  end

  private
  def associations
    case report_comment_action_id
      when ReportCommentAction.report_comment_id
        validate_attributes [:user_id, :content]
      when ReportCommentAction.report_retract_id, ReportCommentAction.report_submit_id, ReportCommentAction.report_approve_id,
          ReportCommentAction.report_reject_id, ReportCommentAction.report_unapprove_id, ReportCommentAction.report_take_control_id,
          ReportCommentAction.report_reimbursement_confirmed_id
        validate_attributes [:user_id]
      when ReportCommentAction.report_update_id
        validate_attributes [:user_id, :updated_field, :updated_from, :updated_to]
      when ReportCommentAction.report_reimbursed_id
        validate_attributes [:user_id, :payment]
      when ReportCommentAction.report_attach_receipt_id
        # todo pending
      when ReportCommentAction.report_detach_receipt_id
        # todo pending
      when ReportCommentAction.expense_add_id, ReportCommentAction.expense_remove_id, ReportCommentAction.expense_reject_id
        validate_attributes [:user_id, :expense_id]
      when ReportCommentAction.expense_update_id
        validate_attributes [:user_id, :expense_id, :updated_field, :updated_from, :updated_to]
      else

    end
  end

  def validate_attributes(items=[])
    return unless items.present?
    items.each do |item|
      if self.send(item).blank?
        val = item
        s_val = val.to_s
        val = s_val.gsub!('_id', '').to_sym if s_val.ends_with?('_id')
        errors.add val, 'cannot be blank'
      end
    end
  end
end
