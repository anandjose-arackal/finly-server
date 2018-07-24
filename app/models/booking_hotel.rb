# == Schema Information
#
# Table name: booking_hotels
#
#  id                :integer          not null, primary key
#  hotel_name        :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_id         :integer
#  parent_type       :string(255)
#  location_id       :integer          not null
#  checkin_datetime  :datetime
#  checkout_datetime :datetime
#  description       :text(65535)
#  hotel_address     :text(65535)
#  cost_id           :integer
#  is_deleted        :boolean          default(FALSE)
#

class BookingHotel < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :location, dependent: :destroy

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :cost

  validates :location, presence: true

  def as_json(options = {})
    {
        id: id,
        hotel_name: hotel_name,
        location: location,
        checkin_datetime: checkin_datetime,
        checkout_datetime: checkout_datetime,
        description: description,
        hotel_address: hotel_address,
        cost: cost
    }
  end
end
