class TravelRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :policy

  has_many :destinations, class_name: "TravelRequestDestination"
end
