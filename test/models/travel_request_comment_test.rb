# == Schema Information
#
# Table name: travel_request_comments
#
#  id                       :integer          not null, primary key
#  travel_request_id        :integer
#  content                  :text(65535)
#  user_id                  :integer
#  note                     :text(65535)
#  previous_value           :text(65535)
#  new_value                :text(65535)
#  edited_field             :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  action_id                :integer
#  booking_id               :integer
#  booking_request_id       :integer
#  is_deleted               :boolean          default(FALSE)
#  delegated_action_user_id :integer
#  deleted_at               :datetime
#

require 'test_helper'

class TravelRequestCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
