# == Schema Information
#
# Table name: report_processor_groups
#
#  id                        :integer          not null, primary key
#  status_id                 :integer          not null
#  is_deleted                :boolean          default(FALSE)
#  payment_file_generated    :boolean          default(FALSE)
#  payment_file_generated_at :datetime         default(NULL)
#  completed_at              :datetime
#  total_amount_id           :integer          not null
#  processed_amount_id       :integer
#  created_by_user_id        :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class ReportProcessorGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
