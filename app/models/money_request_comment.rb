# == Schema Information
#
# Table name: money_request_comments
#
#  id                :integer          not null, primary key
#  money_request_id  :integer          not null
#  comment_action_id :integer          not null
#  user_id           :integer
#  expense_id        :integer
#  payment_id        :integer
#  updated_field     :string(255)
#  updated_from      :text(65535)
#  updated_to        :text(65535)
#  rejected_to_id    :integer
#  content           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#




# todo rename rejected_to_id to modified_user_id
class MoneyRequestComment < ActiveRecord::Base

  default_scope {order(created_at: :desc)}

  belongs_to :money_request
  belongs_to :comment_action, class_name: 'MoneyRequestCommentAction'
  belongs_to :user
  belongs_to :expense
  belongs_to :rejected_to, class_name: 'User'
  belongs_to :payment

  # ACTIONS = {create: 1, retract: 2, submit: 3, approve: 4, auto_approve: 5, reject: 6, unapprove: 7,
  #            take_control: 8, comment: 9, update: 10, credited: 11}

  ACTIONS = {create: 1, retract: 2, submit: 3, approve: 4, approve_and_forward: 5, auto_approve: 6, reject: 7, unapprove: 8,
             take_control: 9, comment: 10, update: 11, credited: 12}

  def generate(u=nil)
    comment = nil
    name = nil
    name_rec = nil
    if self.user.present? and u.present? and u.id == self.user_id
      name = 'You'
    elsif self.user.present?
      name = self.user.name
    end
    if u.present? and self.money_request.user_id == u.id
      name_rec = 'your'
    else
      name_rec = "#{self.money_request.user.name}'s"
    end
    case comment_action_id
      when MoneyRequestCommentAction.id_for(:retract)
        comment = "#{name} retracted the advance request"
      when MoneyRequestCommentAction.id_for(:submit)
        comment = "#{name} submitted the advance request"
      when MoneyRequestCommentAction.id_for(:approve)
        comment = "#{name} approved the advance request"
      when MoneyRequestCommentAction.id_for(:approve_and_forward)
        comment = "#{name} approved and forwarded the advance request to #{rejected_to.name}"
      when MoneyRequestCommentAction.id_for(:auto_approve)
        comment = 'Request auto-approved as no manager is assigned to the user'
      when MoneyRequestCommentAction.id_for(:reject)
        comment = "#{name} rejected the advance request"
        if self.content.present?
          comment += " with a note: '#{self.content}'"
        end
      when MoneyRequestCommentAction.id_for(:unapprove)
        comment = "#{name} unapproved the advance request"
      when MoneyRequestCommentAction.id_for(:take_control)
        comment = "#{name} took control of the advance request"
        if self.content.present?
          comment += " with a note: '#{self.content}'"
        end
      when MoneyRequestCommentAction.id_for(:comment)
        comment = "#{name} commented : #{content}"
      when MoneyRequestCommentAction.id_for(:update)
        comment = "#{name} updated #{updated_field} from #{updated_from} to #{updated_to}"
      when MoneyRequestCommentAction.id_for(:credited_from_virtual_account_to_wallet), MoneyRequestCommentAction.id_for(:credited_from_wallet_to_wallet)
        payment_id = payment.id rescue nil
        comment = "#{name} credited #{name_rec} wallet with Payment ID : #{payment_id}"
        if payment.note.present?
          comment += " , note : #{payment.note}"
        end
      when MoneyRequestCommentAction.id_for(:credited_from_virtual_account_to_card), MoneyRequestCommentAction.id_for(:credited_from_wallet_to_card)
        payment_id = payment.id rescue nil
        comment = "#{name} credited #{name_rec} card with Payment ID : #{payment_id}"
        if payment.note.present?
          comment += " , note : #{payment.note}"
        end
      when MoneyRequestCommentAction.id_for(:credited)
        payment_id = payment.id rescue nil
        comment = "#{name} credited the advance request with Payment ID : #{payment_id}"
        if payment.note.present?
          comment += " , note : #{payment.note}"
        end
    end
    comment
  end

end
