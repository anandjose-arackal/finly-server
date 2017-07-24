# == Schema Information
#
# Table name: admin_review_workflow_levels
#
#  id                       :integer          not null, primary key
#  admin_review_workflow_id :integer          not null
#  position                 :integer          not null
#  admin_reviewer_id        :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  trigger_email            :boolean          default(FALSE), not null
#  reviewer                 :boolean          default(FALSE), not null
#

require 'test_helper'

class AdminReviewWorkflowLevelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
