# == Schema Information
#
# Table name: feedback_types
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class FeedbackTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
