# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  line_1     :text(65535)
#  line_2     :text(65535)
#  line_3     :text(65535)
#  city       :string(255)
#  state_id   :integer
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pin_code   :string(255)
#

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
