# == Schema Information
#
# Table name: tracker_events
#
#  id               :integer          not null, primary key
#  tracker_visit_id :integer          not null
#  http_method      :string(255)
#  app              :string(255)
#  path             :string(255)
#  controller       :string(255)      not null
#  action           :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class TrackerEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
