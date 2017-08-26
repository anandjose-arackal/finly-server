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
#

class BankPaymentRequestComment < ActiveRecord::Base

  belongs_to :action, class_name: "BankPaymentRequestCommentAction"
  belongs_to :bank_payment_request
  belongs_to :user

  # this will generate the comment body from the
  # parameters in the DB

  def retrieve_content
    case self.action_id
      when BankPaymentRequestCommentAction.id_for(:comment)
        return content
      else
        # do nothing?
    end
  end
end
