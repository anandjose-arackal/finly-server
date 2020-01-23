# == Schema Information
#
# Table name: trip_transport_requests
#
#  id                  :bigint           not null, primary key
#  uuid                :string(36)       not null
#  trip_id             :bigint           not null
#  trip_route_id       :bigint           not null
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
  belongs_to :trip
  belongs_to :trip_route
  belongs_to :created_by, class_name: 'User'
  belongs_to :traveller, class_name: 'User'
  belongs_to :company
  belongs_to :budget, class_name: 'Amount'
end
