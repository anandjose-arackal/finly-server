# == Schema Information
#
# Table name: travel_request_destinations
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  travel_request_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  map_id            :string(255)
#

class TravelRequestDestination < ActiveRecord::Base
  validates :name, presence: true
  validates :travel_request_id, presence: true

  belongs_to :travel_request
  has_many :booking_requests

  scope :with_id, ->(id) {where id: id}

  def as_json(options = {})
    {
        id: id,
        name: name,
        map_id: map_id
    }
  end

end
