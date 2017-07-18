# == Schema Information
#
# Table name: individual_kyc_tracks
#
#  id                   :integer          not null, primary key
#  individual_kyc_id    :integer          not null
#  action_resource_id   :integer
#  action_resource_type :string(255)
#  action_id            :integer          not null
#  note                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class IndividualKycTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
