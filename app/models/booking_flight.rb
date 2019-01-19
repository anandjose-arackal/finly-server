# == Schema Information
#
# Table name: booking_flights
#
#  id               :integer          not null, primary key
#  pnr              :string(255)
#  airline          :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :integer
#  parent_type      :string(255)
#  stops            :string(255)
#  ticket_number    :string(255)
#  from_id          :integer          not null
#  to_id            :integer          not null
#  description      :text(65535)
#  terminal         :string(255)
#  cost_id          :integer
#  booking_class_id :integer
#  is_deleted       :boolean          default(FALSE)
#  departure_date   :date
#  departure_time   :time
#  arrival_date     :date
#  arrival_time     :time
#  booking_id       :integer
#  deleted_at       :datetime
#

class BookingFlight < ActiveRecord::Base
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation

  # belongs_to :parent, polymorphic: true
  belongs_to :booking, inverse_of: :booking_flight
  belongs_to :booking_class, class_name: 'BookingFlightClass'
  belongs_to :cost, class_name: 'Amount', dependent: :destroy
  belongs_to :from, class_name: 'Location', dependent: :destroy
  belongs_to :to, class_name: 'Location', dependent: :destroy

  accepts_nested_attributes_for :from
  accepts_nested_attributes_for :to
  accepts_nested_attributes_for :cost

  scope :with_parent_booking_id, ->(id) { where booking_id: id }
  scope :sum_cost, -> { joins(:cost).sum(:value) }

  delegate :request?, to: :booking

  validates :from, presence: true
  validates :to, presence: true
  validates :departure_date, presence: true

  # As front end calls this comment and not description, have to give an alias for validation purpose
  alias_attribute :comment, :description

  field_customization_key :booking_flight
  customizable_validate :comment, presence: false, scope: [:booking, :travel_request, :company], if: :request?
  # validates :comment, presence: true


  def comment_presence
    if comment.blank? and parent.booking_request?
      errors.add :comment, 'cannot be blank'
    end
  end

  def as_json(options={})
    {
        id: id,
        pnr: pnr,
        airline: airline,
        stops: stops,
        ticket_number: ticket_number,
        from: from,
        to: to,
        departure_date: DateUtils.date_formatted(departure_date),
        departure_time: DateUtils.time_formatted(departure_time, military_time: true),
        arrival_date: DateUtils.date_formatted(arrival_date),
        arrival_time: DateUtils.time_formatted(arrival_time, military_time: true),
        description: description,
        terminal: terminal,
        cost: cost,
        booking_class: booking_class
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
