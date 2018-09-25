# == Schema Information
#
# Table name: booking_car_rentals
#
#  id              :integer          not null, primary key
#  pickup_address  :text(65535)
#  car_type        :string(255)
#  car_number      :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  parent_id       :integer
#  parent_type     :string(255)
#  pickup_city_id  :integer          not null
#  drop_city_id    :integer          not null
#  drop_address    :text(65535)
#  pickup_datetime :datetime
#  drop_datetime   :datetime
#  rental_company  :string(255)
#  description     :text(65535)
#  cost_id         :integer
#  pickup_date     :date
#  pickup_time     :time
#  drop_date       :date
#  drop_time       :time
#  is_deleted      :boolean          default(FALSE)
#  booking_id      :integer
#

class BookingCarRental < ActiveRecord::Base
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation

  # belongs_to :parent, polymorphic: true
  belongs_to :booking, inverse_of: :booking_car_rental
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :pickup_city, class_name: 'Location', dependent: :destroy
  belongs_to :drop_city, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :pickup_city
  accepts_nested_attributes_for :drop_city
  accepts_nested_attributes_for :cost

  scope :with_parent_booking_id, ->(id) { where parent_type: 'Booking', parent_id: id }
  scope :sum_cost, -> { joins(:cost).sum(:value) }

  # As front end calls this comment and not description, have to give an alias for validation purpose
  alias_attribute :comment, :description

  delegate :request?, to: :booking

  field_customization_key :booking_car_rental
  customizable_validate :comment, presence: false, scope: [:booking, :travel_request, :company], if: :request?
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
        pickup_time: DateUtils.time_formatted(pickup_time, military_time: true),
        drop_time: DateUtils.time_formatted(drop_time, military_time: true),
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

  def valid_date_range(travel_request)
    travel_from_date = travel_request.from_date
    travel_to_date = travel_request.to_date
    if (travel_from_date and pickup_date < travel_from_date) or (travel_to_date and pickup_date > travel_to_date)
      return false
    end
    if (travel_from_date and drop_date < travel_from_date) or (travel_to_date and drop_date > travel_to_date)
      return false
    end
    true
  end

end
