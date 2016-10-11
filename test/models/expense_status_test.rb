# == Schema Information
#
# Table name: expense_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


require 'test_helper'

class ExpenseStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
