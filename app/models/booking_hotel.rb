# == Schema Information
#
# Table name: booking_hotels
#
#  id                      :integer          not null, primary key
#  reservation_destination :string(255)
#  reservation_start_date  :date
#  reservation_time        :string(255)
#  reservation_end_date    :date
#  hotel_name              :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_id               :integer
#  parent_type             :string(255)
#  hotel_rating            :string(255)
#

class BookingHotel < ActiveRecord::Base
  validates :reservation_destination, presence: true
  validates :reservation_start_date, presence: true
  validates :reservation_end_date, presence: true

  belongs_to :parent, polymorphic: true
end
