# == Schema Information
#
# Table name: booking_car_rentals
#
#  id                     :integer          not null, primary key
#  journey_source         :string(255)
#  journey_destination    :string(255)
#  pickup_address         :text(65535)
#  journey_date           :date
#  pickup_time            :string(255)
#  reservation_start_date :date
#  reservation_end_date   :date
#  car_type               :string(255)
#  car_number             :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_id              :integer
#  parent_type            :string(255)
#  start_time             :text(65535)
#  end_time               :text(65535)
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
  validates :pickup_city, presence: true
  validates :drop_city, presence: true

  validate :acceptable_dates?

  def acceptable_dates?
    return if pickup_date.blank?
    return if drop_date.blank?
    unless pickup_date <= drop_date
      errors.add :pickup_date, 'cannot be after drop date'
    end
  end

  def as_json(options = {})
    # :id, {pickup_city_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
    #     {drop_city_attributes: [:id, :name, :address, :maps_id]},
    #     :pickup_date, :pickup_time, :drop_date, :drop_time, :pickup_address, :drop_address, :description,
    #     :car_type, :car_number, :rental_company, {cost_attributes: [:id, :value, :currency_id]}
    {
        id: id,
        pickup_date: DateUtils.date_formatted(pickup_date),
        drop_date: DateUtils.date_formatted(drop_date),
        pickup_city: pickup_city,
        drop_city: drop_city,
        description: description,
        pickup_address: pickup_address,
        car_type: car_type,
        car_number: car_number,
        drop_address: drop_address,
        rental_company: rental_company,
        cost: cost
    }
  end
end
