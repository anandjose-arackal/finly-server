# == Schema Information
#
# Table name: events
#
#  id                             :integer          not null, primary key
#  name                           :string(255)      not null
#  has_push_notification          :boolean          not null
#  has_mailer                     :boolean          not null
#  configurable_push_notification :boolean          not null
#  configurable_mailer            :boolean          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
