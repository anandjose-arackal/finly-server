# == Schema Information
#
# Table name: bank_payment_request_trails
#
#  id                      :integer          not null, primary key
#  bank_payment_request_id :integer
#  request_status_id       :integer
#  action_user_id          :integer
#  action_user_role_id     :integer
#  modified_user_id        :integer
#  modified_user_role_id   :integer
#  action_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  action_for_user_id      :integer
#  action_for_user_role_id :integer
#

require 'test_helper'

class BankPaymentRequestTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
