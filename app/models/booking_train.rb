# == Schema Information
#
# Table name: booking_trains
#
#  id                  :integer          not null, primary key
#  train_number        :string(255)
#  pnr                 :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  parent_type         :string(255)
#  booking_class       :string(255)
#  from_id             :integer          not null
#  boarding_station    :string(255)
#  to_id               :integer          not null
#  destination_station :string(255)
#  description         :string(255)
#  seat_number         :string(255)
#  cost_id             :integer
#  is_deleted          :boolean          default(FALSE)
#  departure_date      :date
#  departure_time      :time
#  arrival_date        :date
#  arrival_time        :time
#  booking_id          :integer
#

class BookingTrain < ActiveRecord::Base
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation

  # belongs_to :parent, polymorphic: true
  belongs_to :booking, inverse_of: :booking_train
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :from, class_name: 'Location', dependent: :destroy
  belongs_to :to, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :from
  accepts_nested_attributes_for :to
  accepts_nested_attributes_for :cost

  scope :with_parent_booking_id, ->(id) { where parent_type: 'Booking', parent_id: id }
  scope :sum_cost, -> { joins(:cost).sum(:value) }

  # As front end calls this comment and not description, have to give an alias for validation purpose
  alias_attribute :comment, :description

  delegate :request?, to: :booking

  field_customization_key :booking_train
  customizable_validate :comment, presence: false, scope: [:booking, :travel_request, :company], if: :request?
  # validates :comment, presence: true

  validates :from, presence: true
  validates :to, presence: true
  validates :departure_date, presence: true
  validates :departure_time, presence: true

  def as_json(options={})
    {
        id: id,
        train_number: train_number,
        pnr: pnr,
        booking_class: booking_class,
        from: from,
        boarding_station: boarding_station,
        to: to,
        destination_station: destination_station,
        departure_date: DateUtils.date_formatted(departure_date),
        departure_time: DateUtils.time_formatted(departure_time, military_time: true),
        arrival_date: DateUtils.date_formatted(arrival_date),
        arrival_time: DateUtils.time_formatted(arrival_time, military_time: true),
        description: description,
        seat_number: seat_number,
        cost: cost
    }
  end

  def valid_date_range(travel_request)
    travel_from_date = travel_request.from_date
    travel_to_date = travel_request.to_date
    return false if travel_from_date and departure_date < travel_from_date
    return false if travel_to_date and departure_date > travel_to_date
    true
  end

end
