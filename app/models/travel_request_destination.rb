# == Schema Information
#
# Table name: travel_request_destinations
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  source            :string(255)
#  travel_request_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class TravelRequestDestination < ActiveRecord::Base

  belongs_to :location, dependent: :destroy
  belongs_to :travel_request
  # has_many :booking_requests, dependent: :destroy
  has_many :bookings, foreign_key: :destination_id, dependent: :destroy

  validates :travel_request_id, presence: true
  validates :location, presence: true

  accepts_nested_attributes_for :location

  scope :with_id, ->(id) {where id: id}

  def as_json(options = {})
    {
        id: id,
        location: location
    }
  end

end
