class VehicleRate < ActiveRecord::Base
  include SoftDeletable

  belongs_to :policy
  belongs_to :rate, class_name: 'Amount'
  belongs_to :distance_unit, class_name: 'PhysicalUnit'

end
