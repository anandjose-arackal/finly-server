# == Schema Information
#
# Table name: payment_order_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PaymentOrderTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
