# == Schema Information
#
# Table name: booking_hotels
#
#  id               :integer          not null, primary key
#  hotel_name       :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :integer
#  parent_type      :string(255)
#  location_id      :integer          not null
#  description      :text(65535)
#  hotel_address    :text(65535)
#  cost_id          :integer
#  is_deleted       :boolean          default(FALSE)
#  number_of_guests :integer
#  checkin_date     :date
#  checkin_time     :time
#  checkout_date    :date
#  checkout_time    :time
#

class BookingHotel < ActiveRecord::Base
  validates :reservation_destination, presence: true
  validates :reservation_start_date, presence: true
  validates :reservation_end_date, presence: true

  belongs_to :parent, polymorphic: true
end
