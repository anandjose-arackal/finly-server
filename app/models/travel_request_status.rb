# == Schema Information
#
# Table name: travel_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TravelRequestStatus < ActiveRecord::Base

  include Seedable

  def self.values
    [:open, :processing, :retracted, :rejected, :booked, :cancelled] #todo populate statuses and seed
  end
end
