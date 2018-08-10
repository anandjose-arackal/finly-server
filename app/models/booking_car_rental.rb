# == Schema Information
#
# Table name: booking_car_rentals
#
#  id             :integer          not null, primary key
#  pickup_address :text(65535)
#  car_type       :string(255)
#  car_number     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_id      :integer
#  parent_type    :string(255)
#  pickup_city_id :integer          not null
#  drop_city_id   :integer          not null
#  drop_address   :text(65535)
#  rental_company :string(255)
#  description    :text(65535)
#  cost_id        :integer
#  pickup_date    :date
#  pickup_time    :time
#  drop_date      :date
#  drop_time      :time
#

class BookingCarRental < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :pickup_city, class_name: 'Location', dependent: :destroy
  belongs_to :drop_city, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :pickup_city
  accepts_nested_attributes_for :drop_city
  accepts_nested_attributes_for :cost

  validates :pickup_date, presence: true
  validates :drop_date, presence: true
  validates :pickup_city_id, presence: true
  validates :drop_city_id, presence: true
end
