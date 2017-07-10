# == Schema Information
#
# Table name: pin_code_city_id_mappings
#
#  id         :integer          not null, primary key
#  pin_code   :string(255)
#  city_id    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PinCodeCityIdMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
