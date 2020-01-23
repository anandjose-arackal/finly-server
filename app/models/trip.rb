class Trip < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :status, class_name: 'TripStatus'
  belongs_to :policy, optional: true
  belongs_to :estimated_booking_cost, class_name: 'Amount', optional: true
  belongs_to :booking_cost, class_name: 'Amount', optional: true
  belongs_to :advance_requested, class_name: 'Amount', optional: true
  belongs_to :advance_processed, class_name: 'Amount', optional: true
  belongs_to :expenses_total, class_name: 'Amount', optional: true
  belongs_to :trip_type

  has_many :passengers, class_name: 'TripPassenger'
  has_many :routes, class_name: 'TripRoute'

  acts_as_sequenced column: :trip_id, purpose: :trip, editable: false, prefix: 'TRF/'
end