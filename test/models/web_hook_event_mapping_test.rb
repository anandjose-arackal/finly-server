# == Schema Information
#
# Table name: web_hook_event_mappings
#
#  id                :integer          not null, primary key
#  web_hook_id       :integer          not null
#  web_hook_event_id :integer          not null
#  is_deleted        :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#

require 'test_helper'

class WebHookEventMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
