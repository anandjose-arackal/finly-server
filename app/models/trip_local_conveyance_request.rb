# == Schema Information
#
# Table name: trip_local_conveyance_requests
#
#  id              :bigint           not null, primary key
#  uuid            :string(36)       not null
#  trip_id         :bigint           not null
#  trip_route_id   :bigint           not null
#  created_by_id   :integer          not null
#  traveller_id    :integer          not null
#  company_id      :bigint
#  pickup_location :string(255)
#  pickup_at       :datetime
#  drop_at         :datetime
#  description     :text(65535)
#  budget_id       :integer
#

class TripLocalConveyanceRequest < ApplicationRecord
  belongs_to :trip
  belongs_to :trip_route
  belongs_to :created_by, class_name: 'User'
  belongs_to :traveller, class_name: 'User'
  belongs_to :company
  belongs_to :budget, class_name: 'Amount'
end
