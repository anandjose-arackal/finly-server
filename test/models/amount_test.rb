# == Schema Information
#
# Table name: amounts
#
#  id          :integer          not null, primary key
#  value       :float(24)
#  currency_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


require 'test_helper'

class AmountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
