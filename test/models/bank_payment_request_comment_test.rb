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

require 'test_helper'

class BankPaymentRequestCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
