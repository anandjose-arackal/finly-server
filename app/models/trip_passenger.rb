# == Schema Information
#
# Table name: trip_passengers
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  trip_id        :string(255)      not null
#  name           :string(255)
#  contact_number :string(255)
#  email          :string(255)
#

class TripPassenger < ApplicationRecord
  include UUIDHelper

  belongs_to :trip

end
