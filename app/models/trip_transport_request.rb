# == Schema Information
#
# Table name: trip_transport_requests
#
#  id                  :bigint           not null
#  uuid                :string(36)       not null, primary key
#  trip_id             :string(255)      not null
#  trip_route_id       :string(255)      not null
#  created_by_id       :integer          not null
#  traveller_id        :integer          not null
#  company_id          :bigint
#  mode                :string(255)
#  depart_on           :date
#  preferred_timeframe :string(255)
#  budget_id           :integer
#  description         :text(65535)
#

class TripTransportRequest < ApplicationRecord
  include UUIDHelper

  belongs_to :trip, optional: true
  belongs_to :trip_route, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :traveller, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :budget, class_name: 'Amount', optional: true
end
