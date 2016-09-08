# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  push_notification :boolean
#  mailer            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
