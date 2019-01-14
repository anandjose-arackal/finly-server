# == Schema Information
#
# Table name: travel_request_trail_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TravelRequestTrailAction < ApplicationRecord
  include Seedable

  def self.values
    [:submit, :retract, :approve, :reject, :book, :take_control, :cancel,
     :retract_booking, :change_booking, :auto_approve, :selection_requested,
     :selection_confirmed, :selection_approved, :selection_rejected, :booking_confirmed]
  end
end