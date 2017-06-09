# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  latitude       :decimal(30, 15)
#  longitude      :decimal(30, 15)
#  name           :string(255)
#  address        :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  maps_id        :string(255)
#  order          :integer
#

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
