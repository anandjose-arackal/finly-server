# == Schema Information
#
# Table name: level_reviewer_mappings
#
#  id          :integer          not null, primary key
#  level_id    :integer
#  reviewer_id :integer
#  threshold   :decimal(20, 5)   default(0.0)
#  exception   :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_deleted  :boolean          default(FALSE), not null
#

require 'test_helper'

class LevelReviewerMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
