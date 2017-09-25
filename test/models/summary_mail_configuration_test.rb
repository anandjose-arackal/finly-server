# == Schema Information
#
# Table name: summary_mail_configurations
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  period_id              :integer
#  scheduled_day_of_month :integer
#  scheduled_day_of_week  :string(255)
#  scheduled_time         :string(255)
#  personal               :boolean
#  application            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class SummaryMailConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
