# == Schema Information
#
# Table name: payment_trails
#
#  id                                 :integer          not null, primary key
#  date                               :date
#  initiating_account_id              :integer
#  receiving_account_id               :integer
#  initiating_account_type            :string(255)
#  receiving_account_type             :string(255)
#  initiating_account_pre_balance_id  :integer
#  initiating_account_post_balance_id :integer
#  receiving_account_pre_balance_id   :integer
#  receiving_account_post_balance_id  :integer
#  payments_id                        :integer
#  payment_status_id                  :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#

require 'test_helper'

class PaymentTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
