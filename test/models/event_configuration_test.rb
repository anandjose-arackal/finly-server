# == Schema Information
#
# Table name: event_configurations
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  event_id                :integer          not null
#  allow_push_notification :boolean
#  allow_mailer            :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#


require 'test_helper'

class EventConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
