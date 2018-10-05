# == Schema Information
#
# Table name: user_manager_mappings
#
#  id                                 :integer          not null, primary key
#  user_id                            :integer
#  manager_id                         :integer
#  finance_manager_id                 :integer
#  approves_to_id                     :integer
#  approves_finance_to_id             :integer
#  greater_than_amount_id             :integer
#  default                            :boolean          default(FALSE), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  policy_id                          :integer          not null
#  purpose_id                         :integer
#  travel_manager_id                  :integer
#  manager_violation_only             :boolean
#  finance_violation_only             :boolean
#  travel_booking_selector_id         :integer
#  travel_booking_approves_to_id      :integer
#  travel_approves_to_id              :integer
#  approves_to_violation_only         :boolean          default(FALSE)
#  approves_finance_to_violation_only :boolean          default(FALSE)
#


require 'test_helper'

class UserManagerMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
