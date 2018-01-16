# == Schema Information
#
# Table name: customers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  mobile_number :string(255)
#  description   :text(65535)
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  gst           :string(255)
#

require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
