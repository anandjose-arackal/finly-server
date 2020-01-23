class TripTransportRequest < ApplicationRecord
  belongs_to :trip
  belongs_to :trip_route
  belongs_to :created_by, class_name: 'User'
  belongs_to :traveller, class_name: 'User'
  belongs_to :company
  belongs_to :budget, class_name: 'Amount'
end
