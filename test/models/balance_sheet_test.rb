# == Schema Information
#
# Table name: balance_sheets
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cash_in_hand_id          :integer
#  pending_reimbursement_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  pending_advance_id       :integer
#


require 'test_helper'

class BalanceSheetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
