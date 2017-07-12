# == Schema Information
#
# Table name: card_assign_request_tracks
#
#  id                     :integer          not null, primary key
#  card_assign_request_id :integer          not null
#  action_resource_id     :integer
#  action_resource_type   :string(255)
#  action_id              :integer          not null
#  note                   :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class CardAssignRequestTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
