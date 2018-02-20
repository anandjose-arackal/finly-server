# == Schema Information
#
# Table name: web_hook_tracks
#
#  id                :integer          not null, primary key
#  web_hook_id       :integer
#  web_hook_event_id :integer
#  company_id        :integer
#  url               :text(65535)
#  request_body      :text(65535)
#  request_header    :text(65535)
#  response_time     :decimal(10, )
#  response_body     :text(65535)
#  response_status   :integer
#  attempt           :integer
#  last_attempted_at :datetime
#  attempt_success   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class WebHookTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
