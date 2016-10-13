# == Schema Information
#
# Table name: card_transaction_restrictions
#
#  id                     :integer          not null, primary key
#  count                  :integer
#  card_id                :integer
#  period_id              :integer
#  product_combination_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#


require 'test_helper'

class CardTransactionRestrictionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
