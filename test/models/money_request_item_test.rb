# == Schema Information
#
# Table name: money_request_items
#
#  id               :integer          not null, primary key
#  money_request_id :integer          not null
#  category_id      :integer          not null
#  amount_id        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class MoneyRequestItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
