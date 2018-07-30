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
    [:open, :processing, :retracted, :rejected, :booked, :cancelled, :booking_pending,
     :selection_requested, :selection_processing, :selection_confirmed, :booking_confirmed, :completed, :approved]
  end

  def open?
    self.id == TravelRequestStatus.id_for(:open)
  end

  def processing?
    self.id == TravelRequestStatus.id_for(:processing)
  end

  def approved?
    self.id == TravelRequestStatus.id_for(:approved)
  end

  def booked?
    self.id == TravelRequestStatus.id_for(:booked)
  end

  def booking_pending?
    self.id == TravelRequestStatus.id_for(:booking_pending)
  end

  def rejected?
    self.id == TravelRequestStatus.id_for(:rejected)
  end

  def retracted?
    self.id == TravelRequestStatus.id_for(:retracted)
  end

  def completed?
    self.id == TravelRequestStatus.id_for(:completed)
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
