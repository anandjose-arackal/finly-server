# == Schema Information
#
# Table name: bank_payment_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestCommentAction < ApplicationRecord
  include Seedable

  def self.values
    [:submit, :approve, :unapprove, :retract, :reject, :credit, :comment, :payment_edit,
     :add_attachment, :forward, :take_control, :unapprove, :auto_approve, :cancel,
     :add_beneficiary, :remove_beneficiary, :mark_as_credited, :return_control]
  end
end
