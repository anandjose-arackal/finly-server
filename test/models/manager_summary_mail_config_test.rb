# == Schema Information
#
# Table name: manager_summary_mail_configs
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  period_id              :integer          not null
#  starting_day_of_month  :integer
#  scheduled_day_of_month :integer
#  starting_day_of_week   :string(255)
#  scheduled_day_of_week  :string(255)
#  scheduled_time         :string(255)      not null
#  entity_type            :string(255)      not null
#  application            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class ManagerSummaryMailConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
