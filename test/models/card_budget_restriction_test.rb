# == Schema Information
#
# Table name: card_budget_restrictions
#
#  id                     :integer          not null, primary key
#  budget_amount_id       :integer
#  card_id                :integer
#  period_id              :integer
#  product_combination_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class CardBudgetRestrictionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
