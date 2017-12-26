# == Schema Information
#
# Table name: report_processor_groups
#
#  id                        :integer          not null, primary key
#  status_id                 :integer          not null
#  is_deleted                :boolean          default(FALSE)
#  payment_file_generated    :boolean          default(FALSE)
#  payment_file_generated_at :datetime         default(NULL)
#  scheduled_at              :date
#  completed_at              :datetime
#  total_amount_id           :integer          not null
#  processed_amount_id       :integer
#  created_by_user_id        :integer
#  created_by_user_role_id   :integer
#  source_account_id         :integer
#  source_account_type       :string(255)
#  marked_as_completed       :boolean          default(FALSE)
#  payment_type              :string(255)
#  payment_mode              :string(255)
#  company_id                :integer          not null
#  payment_order_id          :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  marked_as_closed          :boolean
#

require 'test_helper'

class ReportProcessorGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
