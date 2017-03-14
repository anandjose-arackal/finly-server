# == Schema Information
#
# Table name: time_expenses
#
#  id             :integer          not null, primary key
#  expense_id     :integer
#  is_deleted     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_object_id :integer
#

require 'test_helper'

class TimeExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
