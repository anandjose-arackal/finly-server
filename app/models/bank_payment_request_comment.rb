# == Schema Information
#
# Table name: bank_payment_request_comments
#
#  id                      :integer          not null, primary key
#  content                 :text(65535)
#  action_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  bank_payment_request_id :integer
#  user_id                 :integer
#  forwarded_to_user_id    :integer
#  note                    :text(65535)
#  previous_value          :text(65535)
#  new_value               :text(65535)
#  edited_field            :text(65535)
#  beneficiary_id          :integer
#

class BankPaymentRequestComment < ApplicationRecord

  belongs_to :action, optional: true, class_name: "BankPaymentRequestCommentAction"
  belongs_to :bank_payment_request, optional: true
  belongs_to :user, optional: true, class_name: "User"
  belongs_to :forwarded_to_user, optional: true, class_name: "User"
  belongs_to :beneficiary, optional: true, class_name: "BankAccount"

  # this will generate the comment body from the
  # parameters in the DB

  validates :user, presence: true
  validates :bank_payment_request_id, presence: true
  validates :action_id, presence: true

  default_scope { order created_at: :desc}

  def retrieve_content(user)
    comment_content = ""

    if user.id == self.user_id
      comment_content += "You have"
    else
      comment_content += "#{self.user&.name} has"
    end

    case self.action_id
      when BankPaymentRequestCommentAction.id_for(:comment)
        return "#{self.user&.name} commented: #{self.content}"
      when BankPaymentRequestCommentAction.id_for(:submit)
        comment_content += " submitted the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:approve)
        comment_content += " approved the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:retract)
        comment_content += " retracted the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:reject)
        comment_content += " rejected the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:credit)
        comment_content += " initiated the credit for this Payment Order"
      when BankPaymentRequestCommentAction.id_for(:forward)
        comment_content += " forwarded the Payment Order to #{forwarded_to_user&.name} for further approval"
      when BankPaymentRequestCommentAction.id_for(:auto_approve)
        comment_content = "Payment Order has been auto approved as there is no reviewer assigned"
      when BankPaymentRequestCommentAction.id_for(:unapprove)
        comment_content += " unapproved the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:take_control)
        comment_content += " taken control of the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:return_control)
        comment_content += " returned control of the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:cancel)
        comment_content += " cancelled the Payment Order"
      when BankPaymentRequestCommentAction.id_for(:add_beneficiary)
        comment_content += " added a beneficiary - Name: #{self.beneficiary&.name}, Account Number: #{self.beneficiary&.account_number}"
      when BankPaymentRequestCommentAction.id_for(:remove_beneficiary)
        comment_content += " removed a beneficiary - Name: #{self.beneficiary&.name}, Account Number: #{self.beneficiary&.account_number}"
      when BankPaymentRequestCommentAction.id_for(:payment_edit)
        comment_content += " updated #{self.edited_field} from #{self.previous_value} to #{self.new_value}, at beneficiary: #{self.beneficiary.name}"
      when BankPaymentRequestCommentAction.id_for(:mark_as_credited)
        comment_content += " marked the payment order as credited"
      else
        return nil
    end

    if self.note.present?
      comment_content += " with a note: #{self.note}"
    end

    comment_content
  end

end
