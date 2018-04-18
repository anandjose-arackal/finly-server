# == Schema Information
#
# Table name: travel_request_trail_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TravelRequestTrailAction < ActiveRecord::Base
  include Seedable

  def self.values
    [:submit, :retract, :approve, :reject, :book, :cancel, :request_change, :change_booking, :auto_approve]
  end
end