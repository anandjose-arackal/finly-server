# == Schema Information
#
# Table name: trip_transport_requests
#
#  id                  :bigint           not null
#  uuid                :string(36)       not null, primary key
#  trip_id             :string(255)
#  created_by_id       :integer
#  traveller_id        :integer
#  company_id          :bigint
#  from_location       :string(255)
#  to_location         :string(255)
#  mode                :string(255)
#  depart_on           :date
#  preferred_timeframe :string(255)
#  budget_id           :integer
#  description         :text(65535)
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class TripTransportRequest < ApplicationRecord
  include SoftDeletable
  include UUIDHelper

  belongs_to :trip, optional: true
  belongs_to :trip_route, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :traveller, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :budget, class_name: 'Amount', optional: true

  has_many :custom_fields, as: :document, class_name: "FormCustomField", primary_key: :uuid

  def as_json(options={})
    {
        id: id,
        from_location: from_location,
        to_location: to_location,
        model: mode,
        depart_on: depart_on,
        preferred_timeframe: preferred_timeframe,
        budget: budget,
        description: description
    }
  end
end
