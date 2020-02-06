# == Schema Information
#
# Table name: trips
#
#  id                        :bigint           not null
#  uuid                      :string(36)       not null, primary key
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
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  trip_type_id              :bigint
#

class Trip < ApplicationRecord
  include SoftDeletable
  include UUIDHelper
  include Sequenced::ActsAsSequenced
  include Forms::Reform::ModelHelper

  owner_scope :created_by

  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :status, class_name: 'TripStatus'
  belongs_to :policy, optional: true
  belongs_to :estimated_booking_cost, class_name: 'Amount', optional: true, dependent: :destroy
  belongs_to :booking_cost, class_name: 'Amount', optional: true, dependent: :destroy
  belongs_to :advance_requested, class_name: 'Amount', optional: true, dependent: :destroy
  belongs_to :advance_processed, class_name: 'Amount', optional: true, dependent: :destroy
  belongs_to :expenses_total, class_name: 'Amount', optional: true, dependent: :destroy
  belongs_to :trip_type

  has_many :custom_fields, as: :document, class_name: "FormCustomField", primary_key: :uuid

  has_many :passengers, class_name: 'TripPassenger', dependent: :destroy, autosave: true
  has_many :routes, class_name: 'TripRoute', dependent: :destroy

  has_many :transport_requests, class_name: "TripTransportRequest", dependent: :destroy
  has_many :hotel_requests, class_name: "TripHotelRequest", dependent: :destroy
  has_many :local_conveyance_requests, class_name: "TripLocalConveyanceRequest", dependent: :destroy

  acts_as_sequenced column: :trip_id, purpose: :trip, editable: false, prefix: 'TRF/'

  scope :non_draft, -> { where.not status_id: TripStatus.id_for(:draft) }

end
