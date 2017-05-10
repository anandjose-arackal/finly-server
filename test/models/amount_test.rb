# == Schema Information
#
# Table name: amounts
#
#  id          :integer          not null, primary key
#  value       :decimal(64, 12)
#  currency_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  USD         :decimal(10, 5)
#  GBP         :decimal(10, 5)
#  CAD         :decimal(10, 5)
#  EUR         :decimal(10, 5)
#


require 'test_helper'

class AmountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
