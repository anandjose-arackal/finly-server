# == Schema Information
#
# Table name: report_comments
#
#  id                       :integer          not null, primary key
#  report_id                :integer          not null
#  report_comment_action_id :integer          not null
#  user_id                  :integer
#  expense_id               :integer
#  updated_field            :string(255)
#  updated_from             :text(65535)
#  updated_to               :text(65535)
#  rejected_to_id           :integer
#  content                  :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  payment_id               :integer
#

require 'test_helper'

class ReportCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
