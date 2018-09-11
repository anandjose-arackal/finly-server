# == Schema Information
#
# Table name: callback_tracks
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  request     :string(255)
#  response    :string(255)
#  entity_id   :integer
#  entity_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  success     :boolean
#

require 'test_helper'

class CallbackTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
