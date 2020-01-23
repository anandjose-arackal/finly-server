# == Schema Information
#
# Table name: trips
#
#  id                        :bigint           not null, primary key
#  uuid                      :string(36)       not null
#  company_id                :integer          not null
#  created_by_id             :integer          not null
#  status_id                 :integer          not null
#  trip_id                   :string(255)
#  policy_id                 :integer
#  start_date                :date
#  end_date                  :date
#  purpose                   :text(65535)
#  estimated_booking_cost_id :integer
#  booking_cost_id           :integer
#  advance_requested_id      :integer
#  advance_processed_id      :integer
#  expenses_total_id         :integer
#  trip_type_id              :bigint
#

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
