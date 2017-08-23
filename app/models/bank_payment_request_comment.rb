# == Schema Information
#
# Table name: bank_payment_request_comments
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  action_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestComment < ActiveRecord::Base

  belongs_to :action, class_name: "BankPaymentRequestCommentAction"
end
