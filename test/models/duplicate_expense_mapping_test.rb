# == Schema Information
#
# Table name: duplicate_expense_mappings
#
#  id                   :integer          not null, primary key
#  expense_id           :integer          not null
#  duplicate_expense_id :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class DuplicateExpenseMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
