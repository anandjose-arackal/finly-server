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




class ReportComment < ApplicationRecord
  belongs_to :report, optional: true
  belongs_to :user, optional: true
  belongs_to :report_comment_action, optional: true
  belongs_to :expense, optional: true
  belongs_to :rejected_to, optional: true, class_name: 'User'
  belongs_to :payment, optional: true

  validates :report_id, presence: true
  validates :report_comment_action_id, presence: true
  validate :associations

  delegate :user_name, to: :user

  default_scope { order created_at: :desc }

  def generate(u = nil)
    comment = nil
    name = nil
    if self.user.present? and u.present? and u.id == self.user_id
      name = 'You'
    elsif self.user.present?
      name = self.user.name
    end

    expense = Expense.unscoped.find_by(id: self.expense_id)

    type = "" # i.e. will form 'an expense...'
    merchant = ""
    if expense
      case expense.expense_type_id
        when ExpenseType.manual_expense_id
          type = "cash"
        when ExpenseType.card_expense_id
          type = "card"
        when ExpenseType.distance_expense_id
          type = "distance" # i.e. will form 'a distance...'
        when ExpenseType.time_expense_id
          type = "time" # i.e. will form  ' a time...'
        when ExpenseType.per_diem_expense_id
          type = "per diem" # i.e. will form ' a per diem...'
        else
          type = ""
      end

      case expense.expense_type_id
        when ExpenseType.distance_expense_id
          merchant = "of ₹#{expense.amount_value}"
        when ExpenseType.time_expense_id
          merchant = "of ₹#{expense.amount_value}"
        when ExpenseType.manual_expense_id, ExpenseType.card_expense_id, ExpenseType.per_diem_expense_id
          merchant = "at : #{expense.merchant_name}"
        else
          merchant = "-unavailable-"
      end

    end

    case report_comment_action_id
      when ReportCommentAction.id_for(:report_comment)
        # Report comment
        comment = "#{name} commented : #{content}"
      when ReportCommentAction.id_for(:report_retract)
        # Report retract
        comment = "#{name} retracted the report"
      when ReportCommentAction.id_for(:report_submit)
        # Report submit
        comment = "#{name} submitted the report"
      when ReportCommentAction.id_for(:report_auto_submit)
        comment = 'Report auto-submitted'
      when ReportCommentAction.id_for(:report_approve)
        # Report approve
        comment = "#{name} approved the report"
      when ReportCommentAction.id_for(:report_auto_approve)
        # Report auto_approve
        if self.report.present? and u.present? and u.id == self.report.user_id
          name = 'you'
        elsif self.user_id.present?
          name = self.user.name
        end
        comment = "Report auto-approved as no manager is assigned to #{name}"
      when ReportCommentAction.id_for(:report_reject)
        # Report reject
        comment = "#{name} rejected the report"
        if content.present?
          comment += " with a note : #{content}"
        end
      when ReportCommentAction.id_for(:report_unapprove)
        # Report unapprove
        comment = "#{name} unapproved the report"
      when ReportCommentAction.id_for(:report_take_control)
        # Report take control
        comment = "#{name} took control of the report"
        if self.content.present?
          comment += " with a note: '#{self.content}'"
        end
      when ReportCommentAction.id_for(:report_update)
        # Report update
        comment = "#{name} updated #{updated_field} from #{updated_from} to #{updated_to}"
      when ReportCommentAction.id_for(:report_settled)
        # Report reimbursed
        payment_id = payment.id if payment.present?
        if payment_id.present?
          comment = "#{name} reimbursed the report with Payment ID : #{payment_id}"
          if payment.note.present?
            comment += " , with a note : #{payment.note}"
          end
        else
          comment = "#{name} settled the report"
        end
      when ReportCommentAction.id_for(:report_settlement_confirmed)
        # Report settlement confirmed
        comment = "#{name} confirmed that the reimbursement is received"
      when ReportCommentAction.id_for(:report_closed)
        # Report closed
        comment = "Report has been marked as closed " + content
      when ReportCommentAction.id_for(:report_attach_receipt)
        # Report attach receipt
        comment = "#{name} attached a receipt to the report"
      when ReportCommentAction.id_for(:report_detach_receipt)
        # Report detach receipt
        comment = "#{name} detached a receipt from the report"
      when ReportCommentAction.id_for(:expense_add)
        # Expense add
        comment = "#{name} added a #{type} expense #{merchant} to the report"
      when ReportCommentAction.id_for(:expense_remove)
        # Expense remove
        comment = "#{name} removed the #{type} expense #{merchant} to the report"
      when ReportCommentAction.id_for(:expense_reject)
        # Expense reject
        comment = "#{name} rejected the #{type} expense #{merchant}"
        if content.present?
          comment += " with a note : #{content}"
        end
      when ReportCommentAction.id_for(:expense_update)
        # Expense update
        if updated_from.blank? and updated_to.present?
          comment = "#{name} updated the #{type} expense #{merchant} : Added a '#{updated_field}' as '#{updated_to}'"
        elsif updated_to.blank? and updated_from.present?
          comment = "#{name} updated the #{type} expense #{merchant} : Cleared the '#{updated_field}' from '#{updated_from}'"
        else
          comment = "#{name} updated the #{type} expense #{merchant} : Set the #{updated_field} from '#{updated_from}' to '#{updated_to}'"
        end
      when ReportCommentAction.id_for(:expense_attach_receipt)
        # adding a receipt to an expense
        comment = "#{name} attached a receipt to the #{type} expense #{merchant}"
      when ReportCommentAction.id_for(:expense_detach_receipt)
        # adding a receipt to an expense
        comment = "#{name} detached a receipt from the #{type} expense #{merchant}"
      when ReportCommentAction.id_for(:expense_update_receipt)
        # adding a receipt to an expense
        comment = "#{name} updated a receipt on the #{type} expense #{merchant}"
      when ReportCommentAction.id_for(:cash_in_hand_deduction_against_reimbursement)
        # deducing cash in hand for reimbursement
        payment_id = payment.id rescue nil
        comment = "#{name} has deducted your cash on hand against reimbursement for this report with Payment ID: #{payment_id}"
      when ReportCommentAction.id_for(:hard_copy_receipt_submitted)
        comment = "#{name} submitted hard copy for a receipt."
      when ReportCommentAction.id_for(:hard_copy_receipt_not_submitted)
        comment = "#{name} marked hard copy not submitted for a receipt."
      else
        # do nothing
    end
    comment
  end

  private
  def associations
    case report_comment_action_id
      when ReportCommentAction.id_for(:report_comment)
        validate_attributes [:user_id, :content]
      when ReportCommentAction.id_for(:report_retract), ReportCommentAction.id_for(:report_submit), ReportCommentAction.id_for(:report_approve),
          ReportCommentAction.id_for(:report_reject), ReportCommentAction.id_for(:report_unapprove), ReportCommentAction.id_for(:report_take_control),
          ReportCommentAction.id_for(:report_reimbursement_confirmed)
        validate_attributes [:user_id]
      when ReportCommentAction.id_for(:report_update)
        validate_attributes [:user_id, :updated_field, :updated_from, :updated_to]
      when ReportCommentAction.id_for(:report_reimbursed)
        validate_attributes [:user_id, :payment]
      when ReportCommentAction.id_for(:report_attach_receipt)
        # todo pending
      when ReportCommentAction.id_for(:report_detach_receipt)
        # todo pending
      when ReportCommentAction.id_for(:expense_add), ReportCommentAction.id_for(:expense_remove), ReportCommentAction.id_for(:expense_reject)
        validate_attributes [:user_id, :expense_id]
      when ReportCommentAction.id_for(:expense_update)
        validate_attributes [:user_id, :expense_id, :updated_field]
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
