# == Schema Information
#
# Table name: travel_request_comment_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TravelRequestCommentAction < ApplicationRecord

  include Seedable

  def self.values
    [:submit, :retract, :approve, :reject, :unapprove, :comment, :take_control, :return_control, :auto_approve,
     :edit_booking, :add_booking, :remove_booking, :reject_booking_request, :selection_requested,:booking_confirmed, :selection_confirmed, :created_by_delegate, :updated_by_delegate, :submitted_by_delegate, :retracted_by_delegate]
  end
end