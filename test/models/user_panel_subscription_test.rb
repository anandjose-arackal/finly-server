# == Schema Information
#
# Table name: user_panel_subscriptions
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  disburse           :boolean
#  expense_management :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class UserPanelSubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
