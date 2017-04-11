# == Schema Information
#
# Table name: payment_order_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PaymentOrderStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
