# == Schema Information
#
# Table name: bank_payment_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestCommentAction < ActiveRecord::Base
  include Seedable

  def self.values
    [:submit, :approve, :unapprove, :retract, :reject, :credit, :comment]
  end
end
