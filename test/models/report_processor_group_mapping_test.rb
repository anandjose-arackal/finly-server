# == Schema Information
#
# Table name: report_processor_group_mappings
#
#  id                         :integer          not null, primary key
#  processor_group_id         :integer          not null
#  user_id                    :integer          not null
#  processor_accountable_id   :integer
#  processor_accountable_type :string(255)
#  amount_id                  :integer          not null
#  completed_at               :datetime
#  marked_as_completed        :boolean          default(FALSE)
#  status_id                  :integer          not null
#  payment_id                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'test_helper'

class ReportProcessorGroupMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
